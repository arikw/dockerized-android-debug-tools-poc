# Proof of Concept: Controlling a Virtual Android Device with Various Debug Tools Using VirtualBox and Docker

This documents describes how to set-up an virtual Android device and how to control it using various tools.

VirtualBox will be used to create a virtual machine running Android, and Docker will be used to create an environment for running the various debug tools: [Android Debug Bridge (adb)](https://developer.android.com/studio/command-line/adb), [Objection](https://github.com/sensepost/objection), and [Frida](https://www.frida.re/).

## Android Virtual Machine

### Setup steps

* Download an Android x86 32bit `.iso` image file [from here](https://osdn.net/projects/android-x86/releases/69704)
    * Use 32bit version for max compatibility
* Create a VirtualBox machine (as similarly done [in this video](https://www.youtube.com/watch?v=pwZ9l9qIVoM) and ), with following configuration:
    * OS: Linux 32 bit (Other)
    * 4 Cores
    * 4096MB Memory
    * Display option Graphics Controller to VBoxVGA and enabled 3D animation
    * Create an 8GB dynamic allocated VDI storage
    * **Load .iso into the Optical Drive**
    * To enable cross-vbox-guests communication (e.g., `adb` from a docker container to android guest), add another `Host-Only` network adapter and use the adapter that is being used in the other virtual machine
* Start machine and choose install
* Create 2 partitions
    * Skip `GPT` creation
    * `New` -> `Primary` -> 4000MB -> `Beginning` -> `Bootable` --> `Write`
    * `New` -> `Logical` -> `Beginning` -> `Write`
    * Select `Quit`
    * Select `sda1`
    * Select `ext4` filesystem
    * Select install `GRUB`
    * Select `read-write` (root)
    * After the installation is complete, remove the .iso from Optical Drive
    * Select `Reboot`
* Enable `Developer options` on Android by going to `Settings` -> `System` -> `About Tablet` -> `Build Number` and pressing 10 times on this menu item
* Enable the following setting in `Settings` -> `System` -> `Developer options`:
    * `Stay awake`
    * `USB debugging`
* Make sure your virtual device is connected via the Wi-Fi network (Android Wi-Fi icon is active) and take a note of the IP address shown at `Settings` -> `System` -> `About Tablet` -> `Status` -> `IP address`

## Android Debug Tools Docker Image

### Setup steps

* [Create a Docker Machine](https://docs.docker.com/machine/install-machine/), if one doesn't exist yet
    * I've used [Docker Toolbox](https://docs.docker.com/toolbox/overview/)
* Go to `VirtualBox Manager` GUI -> `Settings` -> `Shared Folders` and select a folder from your real machine, that will be accessible to the virtual machine. For example, to map "D:\Data" to "/d/misc" inside the VM:
    * `Folder Path`: D:\Data
    * `Folder Name`: /d/misc
    * Enable `Auto-mount`
    * Enable `Make permanent`
* You can use the prebuilt image by:  
    ```
    docker pull arikwe/android-debug-tools
    ```
* Or, you can build the the Docker image locally using the `Dockerfile` found in this repository with the following command:  
    ```
    docker build -t android-debug-tools .
    ```

### Creating and running the Docker container

```
docker run -it --rm -v //d/misc:/misc -p 5555 --name android-debug-tools arikwe/android-debug-tools
```

This will spin up a bash shell inside a Docker container, with the debugging tools to debug Android devices.

*Note: If you chose to build the image locally using the Dockerfile, make sure to remove the "arikwe/" prefix from the image name in the command above.*

----

## Usage Examples

### Android Debug Bridge (adb): Sideloading APK Application Files

You can use `adb` for various tasks, like gaining shell access to the virtual Android device, upload files and sideload APK files

From the bash shell, connect to the Android virtual device using the IP shown in the device `Status` menu item, inside the settings (as noted in the `Android Virtual Machine` setup part) using the following command (replace the IP)

```
adb connect 192.168.99.106
```

After a successful connection, you can sideload APK files, for example, from your host machine's shared folder (e.g., D:\Data), and install them using the following command

```
adb install /misc/my-super-application.apk
```

### Android Debug Bridge (adb): Sideloading Xposed Framework and turn off SSL pinning

[Xposed Framework](https://www.xda-developers.com/xposed-framework-hub/) can be used to turn off device-wide SSL pinning using the [TrustMeAlready](https://repo.xposed.info/module/com.virb3.trustmealready) module
- Just sideload the [Xposed Installer APK](https://forum.xda-developers.com/showthread.php?t=3034811) using adb
- Make sure the app has storage permission
- Open the app, download and install the `Xposed` framework
- Install the TrustMeAlready module
- Reboot the device

### Objection: Turning Off SSL Pinning For A Specific App

You can use [Objection](https://github.com/sensepost/objection) to bypass Android's certificate pinning for a certain application.
This technique is described [here](https://blog.netspi.com/four-ways-bypass-android-ssl-verification-certificate-pinning/).

For example, to patch an APK using Objection:
```shell
objection patchapk -s /misc/my-super-application.apk
adb install /misc/my-super-application.objection.apk
```
Now run the application in Android and turn off the SSL pinning:
```
objection explore
android sslpinning disable
```
or try by using the following single-line command:
```
objection run android sslpinning disable
```

# Related links
* [VirtualBox](https://www.virtualbox.org/)
* [Android Debug Bridge (adb)](https://developer.android.com/studio/command-line/adb)
* [Objection](https://github.com/sensepost/objection)
* [Frida](https://www.frida.re/)
* [Xposed Framework](https://www.xda-developers.com/xposed-framework-hub/)
* [Brida](https://github.com/federicodotta/Brida)