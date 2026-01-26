echo " ____ _____  _    ____ _____ ___ _   _  ____ "
echo "/ ___|_   _|/ \  |  _ \_   _|_ _| \ | |/ ___|"
echo "\___ \ | | / _ \ | |_) || |  | ||  \| | |  _ "
echo " ___) || |/ ___ \|  _ < | |  | || |\  | |_| |"
echo "|____/ |_/_/   \_\_| \_\|_| |___|_| \_|\____|"

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
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest.git -b bq2 -g default,-mips,-darwin,-notdefault

# clone local manifests
echo ">>> Cloning Local Manifests..."
git clone https://github.com/Renelzx/local_manifest.git --depth 1 -b a51_16.0_EvoX .repo/local_manifests

# repo sync
echo ">>> Starting Repo Sync..."
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# Set up build environment
echo ">>> Setup Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
echo ">>> Starting Build..."
lunch lineage_a51-bp4a-userdebug
#make installclean
m evolution

[ -d out ] && ls out/target/product/a51
