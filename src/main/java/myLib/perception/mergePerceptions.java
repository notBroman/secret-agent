package myLib.perception;

import myLib.mapping.Vec2;

import jason.asSemantics.*;
import jason.asSyntax.*;
import jason.bb.*;
import jason.stdlib.*;

import java.util.Iterator;

public class mergePerceptions extends DefaultInternalAction {
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		BeliefBase beliefs = ts.getAg().getBB();
		for(Iterator<Literal> it = beliefs.getPercepts(); it.hasNext();){
			Literal percept = it.next();
			switch(percept.getFunctor()){
				case "lastAction":
					break;
				case "lastActionResult":
					break;
				case "lastActionParams":
					break;
				case "goal":
					// see if the goal is new or has already been seen
					int x = (int)(((NumberTerm)percept.getTerm(0)).solve());
					int y = (int)(((NumberTerm)percept.getTerm(1)).solve());
					Vec2 pos = new Vec2(x, y);
					Literal dest = beliefs.contains(new Atom("destinations"));
					Literal me = beliefs.contains(new Atom("me"));
					int me_x = (int)(((NumberTerm)me.getTerm(0)).solve());
					int me_y = (int)(((NumberTerm)me.getTerm(1)).solve());
					Vec2 me_vec = new Vec2(me_x, me_y);
					pos.add(me_vec);

					Term dest_term = dest.getTerm(0);

					if (dest_term.isMap()) {
						StringTermImpl key = new StringTermImpl(pos.toString());
						if(!dest_term.get(key)){
							dest_term.put(key, new ObjectTermImpl(pos));
						}
					}
					break;
				default:
					break;
			}
		}
	return true;
	}
};
