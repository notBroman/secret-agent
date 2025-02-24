package myLib.perception;

import myLib.mapping.Vec2;

import jason.asSemantics.*;
import jason.asSyntax.*;
import jason.bb.*;
import jason.stdlib.*;
import jason.util.*;

import java.util.*;
import java.util.logging.Logger;
import java.io.*;

public class mergePerceptions extends DefaultInternalAction {
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		Agent ag = ts.getAg();
		BeliefBase beliefs = ag.getBB();
		Logger logger = ag.getLogger();
		for(Iterator<Literal> it = beliefs.getPercepts(); it.hasNext();){
			Literal percept = it.next();
			switch(percept.getFunctor()){
				case "lastAction":
					break;
				case "lastActionResult":
					break;
				case "lastActionParams":
					break;
				case "sim-start":
					break;
				case "goal":
					// see if the goal is new or has already been seen
					Iterator<Literal> me_it = beliefs.getCandidateBeliefs(new PredicateIndicator("me", 2));
					Literal me = me_it.next();
					Vec2 me_vec = new Vec2(me);
					Vec2 goal_pos = new Vec2(percept);
					goal_pos.add(me_vec);
					Iterator<Literal> dest_it = beliefs.getCandidateBeliefs(new PredicateIndicator("destinations", 1));
					ListTerm dest = (ListTerm) dest_it.next().getTerm(0);
					if (dest.isList()){
						// convert it into a list
						List<Term> dest_list = dest.getAsList();
						// iterate through all the goals in destination
						ObjectTerm goal_pos_term = goal_pos.toTerm();
						logger.info("here1");
						if(!dest_list.contains(goal_pos_term)){
							logger.info("here");
							dest_list.add(goal_pos_term);
						}
						
					}

					break;
				case "thing":
					break;
				default:
					break;
			}
		}
	return true;
	}
};
