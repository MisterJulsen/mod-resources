# Mod Resources Repository
A Github repository for hosting web content needed by my mods.

## Find my content on
<p align="center">
  <a href="https://modrinth.com/user/MrJulsen"><img src="https://i.imgur.com/uLIB4gb.png" alt="CurseForge"></a>
  <a href="https://www.curseforge.com/members/mrjulsen/projects"><img src="https://i.imgur.com/XZYlGVF.png" alt="Modrinth"></a>
  <a href="https://discord.gg/AeSbNgvc7f"><img src="https://i.imgur.com/YnDoeHs.png" alt="Discord"></a>
</p>


## maven
A Maven repository where all my mods with a public api are published. Add the following repository to your `build.gradle` to use my apis.

```groovy
repositories {
    maven {
        name = "MrJulsen's Mod Resources"
        url = "https://maven.mrjulsen.net"
    }
}
```
