echo ">>> Starting Cleanup..."
# cleanup
remove_lists=(
.repo/local_manifests
prebuilts/clang/host/linux-x86
device/samsung_slsi/sepolicy
device/samsung/universal9611-common
device/samsung/a51
kernel/samsung/universal9611
out/target/product/a51
vendor/samsung/a51
hardware/samsung_slsi/libbt
)

rm -rf "${remove_lists[@]}"

# init repo
echo ">>> Starting Initializing Repo..."
repo init -u https://github.com/Evolution-X/manifest -b bq2 --git-lfs --depth 1

# clone local manifests
echo ">>> Cloning Local Manifests..."
git clone https://github.com/Renelzx/local_manifest --depth 1 -b a51_16.0_EvoX .repo/local_manifests

# repo sync
echo ">>> Starting Repo Sync..."
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

echo ">>> Fixing patch..."
# Fix: hardware/samsung_slsi/libbt error "could not import blueprint"
LIBBT_BP="hardware/samsung_slsi/libbt/Android.bp"
if [ -f "$LIBBT_BP" ]; then
    echo "  > Patching $LIBBT_BP..."
    # Menambahkan bootstrap: true jika belum ada
    if ! grep -q "bootstrap: true" "$LIBBT_BP"; then
        sed -i 's/name: "libbt_vendor",/name: "libbt_vendor",\n    bootstrap: true,/g' "$LIBBT_BP"
    fi
else
    echo "  ! Warning: $LIBBT_BP Tidak ditemukan. Mungkin sudah dihapus atau path berbeda."
fi

# Set up build environment
echo ">>> Setup Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
echo ">>> Starting Build..."
lunch lineage_a51-bp3a-userdebug
make installclean
m evolution

[ -d out ] && ls out/target/product/a51
