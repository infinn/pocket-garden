![logo Pocket Garden](/image/logo.webp)

Pocket Garden is a game inspired by *Plants vs. Zombies*, built using the Godot Engine. The distinctive features of this project include:

- **Transparent Window Gameplay**: The game can run in a transparent window, allowing it to blend with your desktop or other applications.
- **Background Execution**: The game is designed to run in the background, potentially as a desktop companion or overlay.

## Installation and Requirements

To run or develop this project, you will need:

- **Godot Engine 4.6**: Download and install Godot 4.6 from the official website: [https://godotengine.org/download](https://godotengine.org/download). 

*This project is compatible with Godot 4.6 and may not work with other versions.*

### Running the Project

1. Clone or download this repository.

    ```bash
    git clone https://github.com/infinn/pocket-garden.git
    ```
2. Open Godot 4.6.2
3. Import the project by selecting the `project.godot` file in the root directory.
4. Ensure all asset folders are populated as described above.
5. Run the project from within Godot.

---
## Character

### Plants
![current plants](image\current-plant.png)

| Plant | Sun Cost | HP | Damage | Recharge | Special |
|-------|----------|-----|--------|----------|---------|
| Sunflower | 50 | 600 | - | 7.5s | Generates 25 sun every 24s |
| Peashooter | 100 | 600 | 10 | 7.5s | Fires peas every 1.5s |
| Wall-nut | 50 | 7200 | - | 30s | Defensive wall with 3 damage states |
| Potato Mine | 25 | 600 | 900 | 30s | Proximity mine, 15s arm time |
| Cherry Bomb | 150 | - | 900 | 50s | Explodes in 3x3 area, instant kill |
| Twin Sunflower* | 150 | 60 | - | 50s | Generates 50 sun every 24s |
| Repeater* | 200 | 60 | 20 | 7.5s | Fires 2 peas per shot |
| Tall-nut* | 125 | 14400 | - | 30s | Double HP wall with 3 damage states |

*\*Unlockable in the seed shop*

### Zombies
![current zombies](image\current-zombies.png)

| Zombie | HP | Armor | Speed | Special |
|--------|-----|-------|-------|---------|
| Common Zombie | 270 | 0 | 4.5 | Basic zombie |
| Conehead Zombie | 270 | 370 | 4.7 | Cone helmet with 3 damage states |
| Buckethead Zombie | 270 | 1100 | 4.7 | Bucket helmet, heavy armor |
| Football Zombie | 270 | 1400 | 9.4 | Very fast and heavily armored |
| Screen Door Zombie | 270 | 1100 | 4.7 | Screen door shield |
| Pole Vaulting Zombie | 500 | 0 | 9.4 | Jumps over first plant, then slows to 7.05 |


### Assets

The game assets (sprites, audio files, etc.) are not included in this repository. You must [download](https://drive.google.com/file/d/16UcmrdC7x8x2S2Ctof7quou4SgiKREfU/view) them separately. Ensure you have the following asset folders populated:

- `assests/audio/`: Sound effects for various game events.
- `assests/fonts/`: Font files for UI elements.
- `assests/sprites/`: Images for characters, items, and backgrounds.

## Contributing

We welcome contributions from the community! Since this is an educational project, contributions should focus on improving code quality, adding features, or fixing bugs while maintaining the learning aspect.

### Coding Best Practices

When contributing code, please adhere to the following best practices:

- **GDScript Conventions**: Follow Godot's official GDScript style guide. Use snake_case for variables and functions, PascalCase for classes, and proper indentation (tabs or 4 spaces consistently).
- **Documentation**: Add comments to complex logic. Use Godot's built-in documentation features for scripts.
- **Modularity**: Keep code organized in separate scripts and scenes. Avoid monolithic files.
- **Performance**: Optimize for performance, especially in update loops. Use Godot's profiling tools to identify bottlenecks.
- **Error Handling**: Implement proper error checking and logging.
- **Version Control**: Make small, focused commits with clear messages.

### Pull Request Guidelines

- **Fork and Branch**: Create a fork of the repository and work on a fveature branch.
- **Testing**: Test your changes thoroughly. Ensure the game runs without errors and that new features work as intended.
- **Code Review**: Submit a pull request with a clear description of changes. Be open to feedback and iterate on reviews.
- **No Breaking Changes**: Avoid changes that break existing functionality without discussion.

### Reporting Issues

If you find bugs or have suggestions, please open an issue on the repository. Provide detailed steps to reproduce any bugs.

---
## Disclaimer

**Pocket Garden** is an open-source project created for educational purposes only. It is not affiliated with Electronic Arts (EA) Games, PopCap Games, or any other company. This project is a fan-made recreation inspired by the gameplay of *Plants vs. Zombies*, developed solely to demonstrate the capabilities of the Godot Engine. There is no profit motive, and it is intended for learning and experimentation with game development.