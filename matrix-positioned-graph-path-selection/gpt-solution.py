import matplotlib.pyplot as plt
import numpy as np
from collections import deque

def is_valid_move(matrix, x, y, visited):
    """Check if the move is within the matrix bounds, and the cell is empty and not visited."""
    return 0 <= x < len(matrix) and 0 <= y < len(matrix[0]) and matrix[x][y] == 0 and not visited[x][y]

def find_paths(matrix, start, end):
    """Find all paths from start to end that do not pass through other nodes or overlap."""
    if matrix[start[0]][start[1]] != 0 or matrix[end[0]][end[1]] != 0:
        return []  # Either start or end is invalid

    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]  # Up, Down, Left, Right
    paths = []
    queue = deque([(start, [start])])
    visited = [[False] * len(matrix[0]) for _ in range(len(matrix))]

    while queue:
        (current_x, current_y), path = queue.popleft()
        
        # Mark this cell as visited
        visited[current_x][current_y] = True
        
        if (current_x, current_y) == end:
            paths.append(path)
            continue

        for dx, dy in directions:
            next_x, next_y = current_x + dx, current_y + dy
            if is_valid_move(matrix, next_x, next_y, visited):
                queue.append(((next_x, next_y), path + [(next_x, next_y)]))
                
                # Unmark visited so other paths can use it
                visited[next_x][next_y] = True

    return paths

def visualize_paths(matrix, paths):
    """Visualize the matrix and the paths by marking path cells with the value 2."""
    # Create a copy of the matrix to modify and display
    path_matrix = [row[:] for row in matrix]
    
    for path in paths:
        for (x, y) in path:
            path_matrix[x][y] = 2  # Mark the path cells with 2

    fig, ax = plt.subplots()
    cmap = plt.get_cmap('viridis', 3)  # We use 3 distinct values: 0, 1, and 2
    cbar = ax.imshow(path_matrix, cmap=cmap, origin='upper')
    fig.colorbar(cbar, ticks=[0, 1, 2], label='Cell Types')
    cbar.ax.set_yticklabels(['Empty', 'Obstacle', 'Path'])

    # Customizing the plot
    ax.set_xticks(np.arange(-.5, len(matrix[0]), 1), minor=True)
    ax.set_yticks(np.arange(-.5, len(matrix), 1), minor=True)
    ax.grid(which='minor', color='w', linestyle='-', linewidth=2)
    ax.tick_params(which='both', size=0, labelbottom=False, labelleft=False)
    plt.show()

# Example usage
matrix = [
    [0, 0, 0],
    [1, 0, 1],
    [0, 0, 0]
]
start = (0, 0)
end = (2, 2)

paths = find_paths(matrix, start, end)
visualize_paths(matrix, paths)

