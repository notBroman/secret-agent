package myLib.mapping;

import jason.asSyntax.*;
import jason.NoValueException;

public class Vec2 {
	int x;
	int y;

	public Vec2(int x, int y){
		this.x = x;
		this.y = y;
	}

	public Vec2(Literal l) throws NoValueException{

		this.x = (int)(((NumberTerm)l.getTerm(0)).solve());
		this.y = (int)(((NumberTerm)l.getTerm(1)).solve());
	}

	public Vec2(Term t1, Term t2) throws NoValueException{
		this.x = (int)(((NumberTerm)t1).solve());
		this.y = (int)(((NumberTerm)t2).solve());
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
		return new Vec2((this.x - rhs.x), (this.y - rhs.y));
	}

	@Override
	public String toString(){
		return "(" + this.x + "," + this.y + ")";
	}

	public boolean equal(Vec2 rhs){
		return (this.x == rhs.x && this.y == rhs.y);
	}

	public ObjectTermImpl toTerm(){
		return new ObjectTermImpl(this);
	}

}
