#!/bin/bash

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Diretório do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$PROJECT_DIR/rust"

print_info "Iniciando build da biblioteca Bitcoin SDK Rust..."
print_info "Diretório do projeto: $PROJECT_DIR"

# Verificar se o Rust está instalado
if ! command -v cargo &> /dev/null; then
    print_error "Cargo não encontrado. Por favor, instale o Rust: https://rustup.rs/"
    exit 1
fi

# Verificar se o diretório rust existe
if [ ! -d "$RUST_DIR" ]; then
    print_error "Diretório rust não encontrado: $RUST_DIR"
    exit 1
fi

cd "$RUST_DIR"

# Função para build de uma target específica
build_target() {
    local target=$1
    local output_dir=$2
    
    print_info "Compilando para target: $target"
    
    # Instalar target se não estiver disponível
    rustup target add "$target" || print_warning "Target $target já está instalado ou não é válido"
    
    # Compilar
    cargo build --release --target "$target"
    
    # Copiar biblioteca compilada
    local lib_name
    case "$target" in
        *windows*)
            lib_name="bitcoin_sdk_rust.dll"
            ;;
        *apple*)
            lib_name="libbitcoin_sdk_rust.dylib"
            ;;
        *)
            lib_name="libbitcoin_sdk_rust.so"
            ;;
    esac
    
    local source_path="target/$target/release/$lib_name"
    if [ -f "$source_path" ]; then
        mkdir -p "$output_dir"
        cp "$source_path" "$output_dir/"
        print_info "Biblioteca copiada para: $output_dir/$lib_name"
    else
        print_warning "Biblioteca não encontrada: $source_path"
    fi
}

# Detectar plataforma atual
case "$(uname -s)" in
    Darwin*)
        print_info "Detectado macOS - compilando para targets Apple"
        
        # macOS (Intel)
        build_target "x86_64-apple-darwin" "../ios/Frameworks"
        
        # macOS (Apple Silicon)
        if command -v arch &> /dev/null && arch -arm64 true 2>/dev/null; then
            build_target "aarch64-apple-darwin" "../ios/Frameworks"
        fi
        
        # iOS Simulator
        build_target "x86_64-apple-ios" "../ios/Frameworks"
        build_target "aarch64-apple-ios-sim" "../ios/Frameworks"
        
        # iOS Device
        build_target "aarch64-apple-ios" "../ios/Frameworks"
        ;;
        
    Linux*)
        print_info "Detectado Linux - compilando para targets Linux e Android"
        
        # Linux
        build_target "x86_64-unknown-linux-gnu" "../android/src/main/jniLibs/x86_64"
        
        # Android targets (requer NDK)
        if [ -n "$ANDROID_NDK_HOME" ] || [ -n "$NDK_HOME" ]; then
            print_info "Android NDK encontrado - compilando para Android"
            
            # Configurar CC para Android (se necessário)
            export CC_aarch64_linux_android="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang"
            export CC_armv7_linux_androideabi="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang"
            export CC_i686_linux_android="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android21-clang"
            export CC_x86_64_linux_android="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang"
            
            build_target "aarch64-linux-android" "../android/src/main/jniLibs/arm64-v8a"
            build_target "armv7-linux-androideabi" "../android/src/main/jniLibs/armeabi-v7a"
            build_target "i686-linux-android" "../android/src/main/jniLibs/x86"
            build_target "x86_64-linux-android" "../android/src/main/jniLibs/x86_64"
        else
            print_warning "Android NDK não encontrado. Defina ANDROID_NDK_HOME para compilar para Android"
        fi
        ;;
        
    MINGW*|CYGWIN*|MSYS*)
        print_info "Detectado Windows - compilando para targets Windows"
        
        # Windows
        build_target "x86_64-pc-windows-msvc" "../windows"
        build_target "i686-pc-windows-msvc" "../windows"
        ;;
        
    *)
        print_warning "Plataforma não reconhecida: $(uname -s)"
        print_info "Tentando compilar para target padrão..."
        cargo build --release
        ;;
esac

print_info "Build concluído!"

# Gerar header C se cbindgen estiver disponível
if command -v cbindgen &> /dev/null; then
    print_info "Gerando header C..."
    cbindgen --config cbindgen.toml --crate bitcoin_sdk_rust --output ../bitcoin_sdk.h
    print_info "Header gerado: ../bitcoin_sdk.h"
else
    print_warning "cbindgen não encontrado. Header C não será gerado automaticamente."
fi

print_info "✅ Build da biblioteca Bitcoin SDK Rust concluído com sucesso!" 