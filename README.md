[![View Maze_Wandering on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://jp.mathworks.com/matlabcentral/fileexchange/178374-maze_wandering)

# Maze Wandering Simulation

This script simulates a maze wandering experience with a first-person perspective (FPS) view. Below is a summary and detailed explanation of the parameters used in the script.

## Parameters

### Maze Parameters
- **`passageWidth`**: The width of the passages in the maze. Set to `8`.
- **`wallThickness`**: Thickness of the walls in the maze. Set to `5`.
- **`sz_map`**: The size of the maze map. Set to `[20, 10]`.
- **`mapResolution`**: Resolution of the map grid used for creating the maze.

### Player Parameters
- **`player.pos`**: The initial position of the player in the maze. Determined by the maze layout.
- **`player.angle`**: Initial viewing angle of the player, set to `90` degrees.
- **`Angle`**: Field of view of the player in degrees. Set to `60`.
- **`dAngle`**: The rotation increment for the player, set to `5` degrees.
- **`n`**: The number of rays used for ray casting, set to `51`.
- **`r`**: Player's view distance. Initially set to `15`.

### Visualization Parameters
- **`m`**: Scaling factor for FPS view rendering. Set to `200`.
- **`view_range_ini`**: Initial viewing range for the bird's-eye view. Set to `100`.
- **`K`**: Gain factor determining the height limit of the viewpoint in the FPS view. Set to `3`.

## Functions

### Maze Creation
The maze is created using the `mapMaze` function with the specified parameters. The maze walls and goal area are set up using logical matrix operations. Boundaries are extracted using `bwboundaries` for rendering.

### Ray Casting
Ray casting is implemented to simulate the player's vision within the maze. It calculates intersections between the player's field of view and the maze walls. This data is used to render the FPS view and detect collisions.

### Visualization
The simulation includes two visualizations:
1. **Bird's-eye view:** Displays the maze layout, player position, and ray casting.
2. **FPS view:** Simulates the player's perspective within the maze.

### Player Actions
The player can perform the following actions using keyboard inputs:
- Rotate clockwise (`e`) or counterclockwise (`r`).
- Move forward, backward, left, or right using arrow keys.
- Zoom in (`w`) or out (`q`) in the FPS view.
- Reset view and position with specific keys (`t`, `z`, `x`).

### Collision Detection
The `Cross` function determines if the player's view intersects with maze walls. Intersection points are used for rendering the FPS view and detecting when the player reaches the goal.

### Goal Detection
If the player reaches the goal area, a message box appears, and the simulation resets or ends.

## Example Usage
To run the simulation, simply execute the script in MATLAB. Use keyboard controls to navigate through the maze and reach the goal.

## Key Features
- Customizable maze size, passage width, and wall thickness.
- Real-time FPS rendering with adjustable view range and zoom.
- Interactive navigation and collision detection.

This script can be expanded further to include more complex mazes, additional visual effects, or AI-controlled players.
