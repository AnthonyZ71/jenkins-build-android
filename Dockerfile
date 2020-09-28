FROM sentinel:5000/jenkins-build-base:latest

## Configuration for Android development
## Check for latest version way down in the "Command line tools only" section:
## https://developer.android.com/studio
## have to run android studio -> tools -> sdkmanager -> android sdk -> sdk tools -> build-tools -> show package details to find latest build-tool verions

ARG android_sdk_ver=6609375_latest

ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV ANDROID_HOME="${ANDROID_SDK_ROOT}"
ENV PATH=$PATH:/usr/local/android-sdk/cmdline-tools/tools:/usr/local/android-sdk/cmdline-tools/tools/bin:/usr/local/android-sdk/platform-tools

USER root

RUN \
    mkdir ${ANDROID_SDK_ROOT} && \
    chown -R jenkins:jenkins ${ANDROID_SDK_ROOT} && \
    echo "Installing prerequisites" && \
    apt-get update && \
    apt-get install -y \
        unzip \
        && \
    rm -fr /var/lib/apt/lists/* && \
    apt-get clean

USER jenkins

RUN \
    echo "Downloading Android command line tools" && \
    cd /home/jenkins/ && \
    curl "https://dl.google.com/android/repository/commandlinetools-linux-${android_sdk_ver}.zip" \
         -o "commandlinetools-linux-${android_sdk_ver}.zip" && \
    echo "Unpacking Android command line tools" && \
    unzip "commandlinetools-linux-${android_sdk_ver}.zip" -d "${ANDROID_SDK_ROOT}/cmdline-tools/" && \
    /bin/rm "commandlinetools-linux-${android_sdk_ver}.zip" && \
    echo "Accepting licenses" && \
    yes | sdkmanager --licenses && \
    echo "Updating" && \
    sdkmanager --update && \
    echo "Installing build-tools" && \
    yes | sdkmanager \
        "platforms;android-28" "platforms;android-29" \
        "build-tools;28.0.3" "build-tools;29.0.3" \
        "extras;google;m2repository" "extras;android;m2repository"

USER root

ARG BUILD_DATE
ARG IMAGE_NAME
ARG IMAGE_VERSION
LABEL build-date="$BUILD_DATE" \
      description="Image for Android development" \
      summary="Android command line tools installed" \
      name="$IMAGE_NAME"  \
      release="$IMAGE_VERSION" \
      version="$IMAGE_VERSION"
