package myLib.perception;

import myLib.mapping.Vec2;

import jason.asSemantics.*;
import jason.asSyntax.*;
import jason.bb.*;
import jason.stdlib.*;
import jason.util.*;

import java.util.*;

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
					Literal me = beliefs.contains(new Atom("me"));
					Vec2 me_vec = new Vec2((int)(((NumberTerm)me.getTerm(0)).solve()),
								(int)(((NumberTerm)me.getTerm(1)).solve()));
					Vec2 goal_pos = new Vec2((int)(((NumberTerm)percept.getTerm(0)).solve()),
								 (int)(((NumberTerm)percept.getTerm(1)).solve()));
					goal_pos.add(me_vec);

					Literal dest = beliefs.contains(new Atom("destinations"));
					if (dest.isList()){
						// convert it into a list
						List<Term> dest_list = dest.getTerms();
						// iterate through all the goals in destination
						ObjectTerm goal_pos_term = goal_pos.toTerm();
						if(!dest_list.contains(goal_pos_term)){
							dest_list.add(goal_pos_term);
							// abolish destinations belief an reinstate it
							beliefs.abolish();
							beliefs.add();
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
