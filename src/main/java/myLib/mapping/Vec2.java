package myLib.mapping;

public class Vec2 {
	int x;
	int y;

	public Vec2(int x, int y){
		this.x = x;
		this.y = y;
	}

	public void add(Vec2 rh){
		this.x += rh.x;
		this.y += rh.y;
	}

	public void sub( Vec2 rh){
		this.x -= rh.x;
		this.y -= rh.y;
	}

	public Vec2 distance( Vec2 rh){
		return new Vec2((this.x - rh.x), (this.y - rh.y));
	}

	@Override
	public String toString(){
		return "(" + this.x + "," + this.y + ")";
	}

}
