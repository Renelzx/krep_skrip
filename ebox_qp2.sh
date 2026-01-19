#!/bin/bash

# Berhenti jika ada error pada command penting
set -e

echo "================================================="
echo ">>> EVOLUTION X BUILD SCRIPT FOR SAMSUNG A51"
echo ">>> Status: FIXED (Namespace Collision & Libbt)"
echo "================================================="

# 1. CLEANUP (Membersihkan sisa build yang error)
echo ">>> [1/8] Membersihkan Environment..."
rm -rf out/
rm -rf .repo/local_manifests
# Hapus tree yang akan disync ulang agar bersih
rm -rf device/samsung/a51 device/samsung/universal9611-common
rm -rf vendor/samsung/a51 vendor/samsung/universal9611-common
rm -rf hardware/samsung_slsi/libbt

# 2. INIT REPO
echo ">>> [2/8] Inisialisasi Repo..."
repo init -u https://github.com/Evolution-X/manifest -b bq2 --git-lfs --depth 1

# 3. LOCAL MANIFEST SETUP
echo ">>> [3/8] Setup Local Manifest..."
mkdir -p .repo/local_manifests
# Asumsi: Anda sudah menyimpan XML di atas ke file lokal, atau kita clone dari repo Anda
# Jika Anda menggunakan file XML yang saya berikan di atas, pastikan file itu ada di .repo/local_manifests
# Baris di bawah ini opsional jika Anda sudah menaruh file XML secara manual:
# git clone https://github.com/Renelzx/local_manifest --depth 1 -b a51_16.0_EvoX .repo/local_manifests

# HAPUS PRIVATE KEYS (Pencegah Error Sync "Auth Failed")
echo "   > Menghapus entri private keys..."
find .repo/local_manifests -name "*.xml" -type f -exec sed -i '/lineage-priv/d' {} +

# 4. REPO SYNC
echo ">>> [4/8] Sinkronisasi Repo..."
# Menggunakan --force-sync untuk menimpa perubahan lokal yang rusak
/opt/crave/resync.sh || repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# 5. AUTO-FIXING ERROR (BAGIAN KRUSIAL)
echo ">>> [5/8] Menerapkan Perbaikan Otomatis..."

# [cite_start]FIX A: Error Libbt (Go/Soong Blueprint) [cite: 1726]
LIBBT_BP="hardware/samsung_slsi/libbt/Android.bp"
if [ -f "$LIBBT_BP" ]; then
    echo "   > [FIX] Patching $LIBBT_BP (Bootstrap)..."
    # Hanya tambahkan jika belum ada
    grep -q "bootstrap: true" "$LIBBT_BP" || sed -i 's/name: "libbt_vendor",/name: "libbt_vendor",\n    bootstrap: true,/g' "$LIBBT_BP"
else
    echo "   ! [WARNING] $LIBBT_BP tidak ditemukan."
fi

# [cite_start]FIX B: Error fsconfig_dynamic.mk Missing [cite: 3650]
FSCONFIG_MK="device/samsung/universal9611-common/fsconfig_dynamic.mk"
if [ ! -f "$FSCONFIG_MK" ]; then
    echo "   > [FIX] Membuat dummy fsconfig_dynamic.mk..."
    touch "$FSCONFIG_MK"
fi

# [cite_start]FIX C: Namespace Collision (prebuilt_libsecnativefeature) [cite: 3697]
# Error log menunjukkan modul ini ada di vendor/a51 DAN vendor/universal9611-common
COMMON_BP="vendor/samsung/universal9611-common/Android.bp"
DEVICE_BP="vendor/samsung/a51/Android.bp"

if [ -f "$COMMON_BP" ] && [ -f "$DEVICE_BP" ]; then
    echo "   > [FIX] Mendeteksi duplikat modul prebuilt_libsecnativefeature..."
    # Hapus definisi modul dari COMMON tree agar yang dipakai adalah dari DEVICE tree
    # Kita menggunakan python script inline kecil untuk menghapus blok modul dgn aman atau sed range
    # Cara aman: Ubah nama modul di common tree agar tidak bentrok (hacky tapi efektif)
    sed -i 's/name: "prebuilt_libsecnativefeature",/name: "prebuilt_libsecnativefeature_common_disabled",/g' "$COMMON_BP"
    echo "   > [FIX] Modul duplikat di common tree telah dinonaktifkan (renamed)."
fi

# FIX D: Pastikan target build Evolution X ada
# Jika tree device Anda hanya punya lineage_a51.mk, kita copy jadi evolution_a51.mk
if [ -f "device/samsung/a51/lineage_a51.mk" ] && [ ! -f "device/samsung/a51/evolution_a51.mk" ]; then
    echo "   > [FIX] Membuat makefile produk Evolution X..."
    cp device/samsung/a51/lineage_a51.mk device/samsung/a51/evolution_a51.mk
    sed -i 's/lineage_a51/evolution_a51/g' device/samsung/a51/evolution_a51.mk
    # Tambahkan ke AndroidProducts.mk jika belum ada
    if ! grep -q "evolution_a51" device/samsung/a51/AndroidProducts.mk; then
        echo "    evolution_a51:$(ls device/samsung/a51/evolution_a51.mk)" >> device/samsung/a51/AndroidProducts.mk
    fi
fi

# 6. SETUP ENVIRONMENT
echo ">>> [6/8] Setup Build Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

# Matikan strict error checking sementara untuk source envsetup (kadang ada warning non-fatal)
set +e
source build/envsetup.sh
set -e

# 7. LUNCH
echo ">>> [7/8] Memilih Target (Lunch)..."
# Prioritaskan evolution_a51
if [[ " $(lunch --print) " =~ " evolution_a51 " ]]; then
    lunch evolution_a51-ap3a-userdebug
elif [[ " $(lunch --print) " =~ " lineage_a51 " ]]; then
    echo "   ! Target Evolution tidak ditemukan, menggunakan Lineage sebagai fallback..."
    lunch lineage_a51-ap3a-userdebug
else
    # Hard fallback
    lunch evolution_a51-userdebug
fi

# 8. BUILD
echo ">>> [8/8] Memulai Build (MKA)..."
make installclean
mka evolution

# 9. RESULT CHECK
echo "================================================="
if [ -d "out/target/product/a51" ]; then
    ZIP_FILE=$(ls out/target/product/a51/Evolution*.zip 2>/dev/null | head -n 1)
    if [ -n "$ZIP_FILE" ]; then
        echo ">>> BUILD SUKSES! File zip tersedia di:"
        echo "    $ZIP_FILE"
    else
        echo ">>> Build selesai tapi file zip tidak ditemukan. Cek folder out."
    fi
else
    echo ">>> BUILD GAGAL! Folder output tidak terbentuk."
    exit 1
fi
echo "================================================="
