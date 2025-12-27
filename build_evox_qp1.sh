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
)

rm -rf "${remove_lists[@]}"

# init repo
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest.git -b bq1 -g default,-mips,-darwin,-notdefault

# clone local manifests
git clone https://github.com/Renelzx/local_manifest --depth 1 -b a51_16.0_EvoX .repo/local_manifests

# repo sync
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# Set up build environment
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_a51-bp3a-userdebug
make installclean
m evolution

[ -d out ] && ls out/target/product/a51
