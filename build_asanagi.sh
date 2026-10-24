#!/bin/bash

set -e

echo "================================================="
echo ">>> GKI 6.1 KERNEL BUILD SCRIPT FOR MEIZU 21"
echo ">>> Features: FinaSU + SuSFS (asanagi branch)"
echo "================================================="

echo ">>> [1/7] Membersihkan Environment..."
rm -rf out/dist out/*.zip
rm -rf AnyKernel3/

echo ">>> [2/7] Inisialisasi Repo ACK GKI 6.1..."
repo init -u https://android.googlesource.com/kernel/manifest -b common-android14-6.1 --depth=1

echo ">>> [3/7] Sinkronisasi Toolchain & Prebuilts..."
/opt/crave/resync.sh || repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

echo ">>> [4/7] Mengambil Source Kernel Meizu (branch asanagi)..."
rm -rf common
git clone --depth=1 https://github.com/Renelzx/kernel_meizu_m2461 -b asanagi common

echo ">>> [5/7] Menjalankan Pre-build Checks..."

export TZ="Asia/Jakarta"

echo ">>> [6/7] Memulai Kompilasi Kernel (Kleaf/Bazel)..."
mkdir -p out/dist
tools/bazel run //common:kernel_aarch64_dist -- --dist_dir=out/dist

echo ">>> [7/7] Memeriksa Hasil & Membuat AnyKernel3 Zip..."
echo "================================================="

if [ -f "out/dist/Image" ]; then
    echo ">>> Kompilasi Image Berhasil! Mengemas ke AnyKernel3..."
    
    git clone --depth=1 https://github.com/osm0sis/AnyKernel3 AnyKernel3
    
    cp out/dist/Image AnyKernel3/Image
    
    sed -i 's/do.devicecheck=1/do.devicecheck=0/g' AnyKernel3/anykernel.sh
    sed -i 's/is_slot_device=0/is_slot_device=1/g' AnyKernel3/anykernel.sh
    
    cd AnyKernel3
    ZIP_NAME="Kernel_Meizu21_GKI6.1_FinaSU_SuSFS_$(date +%Y%m%d_%H%M).zip"
    zip -r9 "../out/${ZIP_NAME}" * -x .git README.md *placeholder
    cd ..
    
    echo "================================================="
    echo ">>> BUILD SUKSES! Flashable zip tersedia di:"
    echo "    out/${ZIP_NAME}"
    echo "================================================="
else
    echo "================================================="
    echo ">>> BUILD GAGAL! File out/dist/Image tidak ditemukan."
    echo "================================================="
    exit 1
fi
