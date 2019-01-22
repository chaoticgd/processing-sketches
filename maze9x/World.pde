import java.awt.Point;

static final int BB = -99;
static final int BD = -50;
static final int BN = 0;

static final int[][] BRICK = new int[][] {
  { BB, BB, BB, BB, BB, BB, BB, BB },
  { BB, BN, BN, BN, BN, BN, BN, BD },
  { BB, BN, BN, BN, BN, BN, BN, BD },
  { BB, BD, BD, BD, BD, BD, BD, BD },
  { BB, BB, BB, BB, BB, BB, BB, BB },
  { BN, BN, BN, BD, BB, BN, BN, BN },
  { BN, BN, BN, BD, BB, BN, BN, BN },
  { BD, BD, BD, BD, BB, BD, BD, BD }
};

private final color ___ = #000000;
private final color RED = #ff0000;
private final color YEL = #ffff00;
private final color GRE = #00ff00;
private final color CYA = #00ffff;
private final color BLU = #0000ff;
private final color MAG = #ff00ff;

interface World {
  
  int width();
  int height();
  
  boolean isTileOccupied(Point tile);
  color getColour(Point tile);
  color getPixel(Point tile, PVector uv);
}

class FixedMaze implements World {
  
  int width() {
    return WORLD_WIDTH;
  }
  
  int height() {
    return WORLD_HEIGHT;
  }
  
  boolean isTileOccupied(Point tile) {
    if(tile.x < 0 || tile.y < 0 || tile.x >= WORLD_WIDTH || tile.y >= WORLD_HEIGHT) {
      return true;
    }
    
    return world[tile.y][tile.x] != ___;
  }
  
  color getColour(Point tile) {
    return world[tile.y][tile.x];
  }
  
  color getPixel(Point tile, PVector uv) {
    color sample = world[tile.y][tile.x];
    int detail = BRICK[int(uv.y * 8)][int(uv.x * 8)];
    return color(red(sample) + detail, green(sample) + detail, blue(sample) + detail);
  }
  
  private final int WORLD_WIDTH = 16;
  private final int WORLD_HEIGHT = 8;
  
  private final color[][] world = new color[][] {
     { MAG, RED, MAG, RED, MAG, RED, MAG, RED, MAG, RED, MAG, RED, MAG, RED, MAG, RED },
     { RED, ___, BLU, ___, ___, ___, ___, MAG, ___, ___, ___, BLU, ___, ___, ___, MAG },
     { MAG, ___, CYA, ___, BLU, BLU, ___, RED, ___, YEL, ___, CYA, CYA, ___, GRE, RED },
     { RED, ___, GRE, ___, BLU, ___, BLU, MAG, ___, YEL, ___, ___, ___, ___, ___, MAG },
     { MAG, ___, ___, ___, BLU, ___, ___, RED, ___, RED, GRE, GRE, BLU, ___, YEL, RED },
     { RED, ___, BLU, ___, BLU, BLU, ___, ___, ___, RED, ___, ___, CYA, ___, ___, MAG },
     { MAG, ___, BLU, ___, ___, ___, ___, RED, ___, ___, ___, BLU, ___, ___, ___, RED },
     { RED, MAG, RED, MAG, RED, MAG, RED, MAG, MAG, RED, MAG, RED, MAG, RED, MAG, RED }
  };
}

class ProceduralMaze implements World {
  
  // Return fake values for the width and height.
  int width() {
    return 0;
  }
  
  int height() {
    return 0;
  }
  
  boolean isTileOccupied(Point tile) {
    return tile.x % 2 == 0 && tile.y % 2 == 0;
  }
  
  color getColour(Point tile) {
    return RED;
  }
  
  color getPixel(Point tile, PVector uv) {
    color sample = color(random(0, 255), random(0, 255), random(0, 255));
    int detail = BRICK[int(uv.y * 8)][int(uv.x * 8)];
    return color(red(sample) + detail, green(sample) + detail, blue(sample) + detail);
  }
}
