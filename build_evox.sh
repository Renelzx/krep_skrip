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
# Fix 1: libbt blueprint error
LIBBT_BP="hardware/samsung_slsi/libbt/Android.bp"
if [ -f "$LIBBT_BP" ]; then
    echo "   > Patching libbt..."
    grep -q "bootstrap: true" "$LIBBT_BP" || sed -i 's/name: "libbt_vendor",/name: "libbt_vendor",\n    bootstrap: true,/g' "$LIBBT_BP"
fi

# Fix 2: Cek fsconfig_dynamic.mk
FS_CONFIG="device/samsung/universal9611-common/fsconfig_dynamic.mk"
if [ ! -f "$FS_CONFIG" ]; then
    echo "   > [WARNING] fsconfig_dynamic.mk hilang! Membuat file dummy untuk mencegah error..."
    touch "$FS_CONFIG"
    echo "# Dummy fsconfig" > "$FS_CONFIG"
fi

# Set up build environment
echo ">>> Setup Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
source build/envsetup.sh

# Build the ROM
echo ">>> Starting Build..."
lunch lineage_a51-bp4a-userdebug
make installclean
m evolution

[ -d out ] && ls out/target/product/a51
