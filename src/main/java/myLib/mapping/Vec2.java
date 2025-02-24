package myLib.mapping;

import jason.util.ObjectTermImpl;

public class Vec2 {
	int x;
	int y;

	public Vec2(int x, int y){
		this.x = x;
		this.y = y;
	}

	public void add(Vec2 rhs){
		this.x += rhs.x;
		this.y += rhs.y;
	}

	public void sub( Vec2 rhs){
		this.x -= rhs.x;
		this.y -= rhs.y;
	}

	public Vec2 distance( Vec2 rhs){
		return new Vec2((this.x - rhs.x), (this.y - rh.y));
	}

	@Override
	public String toString(){
		return "(" + this.x + "," + this.y + ")";
	}

	public boolean equal(Vec2 rhs){
		return (this.x == rhs.x && this.y == rh.y);
	}

	public ObjectTermImpl toTerm(){
		return ObjectTermImpl(this);
	}

}
