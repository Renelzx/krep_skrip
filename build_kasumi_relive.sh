echo " ____ _____  _    ____ _____ ___ _   _  ____ "
echo "/ ___|_   _|/ \  |  _ \_   _|_ _| \ | |/ ___|"
echo "\___ \ | | / _ \ | |_) || |  | ||  \| | |  _ "
echo " ___) || |/ ___ \|  _ < | |  | || |\  | |_| |"
echo "|____/ |_/_/   \_\_| \_\|_| |___|_| \_|\____|"

# 1. Cleanup
echo ">>> Cleaning up old directories..."
remove_lists=(
  .repo/local_manifests
  device/xiaomi/davinci
  kernel/xiaomi/sm6150
  vendor/xiaomi/sm6150-common
  hardware/xiaomi
  out/target/product/davinci
)
rm -rf "${remove_lists[@]}"

# 2. Initialize Repo (Kasumi)
echo ">>> Starting Initializing Repo..."
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Kasumi-reLive/manifest.git -b kasumi-v1 -g default,-mips,-darwin,-notdefault

# 3. Clone Local Manifests
echo ">>> Cloning Local Manifests for Davinci..."
git clone https://github.com/Renelzx/local_manifest.git --depth 1 -b davinci-11 .repo/local_manifests

# 4. Repo Sync
echo ">>> Starting Repo Sync..."
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# 5. Set up build environment
echo ">>> Setup Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# 6. Build the ROM
echo ">>> Starting Build..."
play live kasumi_davinci-userdebug
#mka bandori

# 7. Check output
[ -d out ] && ls out/target/product/davinci
