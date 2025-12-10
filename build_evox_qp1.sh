# cleanup
remove_lists=(
.repo/local_manifests
prebuilts/clang/host/linux-x86
device/qcom/sepolicy
device/qcom/sepolicy-legacy-um
device/qcom/sepolicy_vndr/legacy-um
device/xiaomi/sdm660-common
device/xiaomi/platina
kernel/xiaomi/sdm660
out/target/product/platina
)

rm -rf "${remove_lists[@]}"

# init repo
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest -b bp3a -g default,-mips,-darwin,-notdefault

# clone local manifests
git clone https://github.com/Renelzx/local_manifest --depth 1 -b platina-16.0_EvoX .repo/local_manifests

# repo sync
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh


# Set up build environment
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_platina-bp3a-userdebug
make installclean
m evolution

[ -d out ] && ls out/target/product/platina
