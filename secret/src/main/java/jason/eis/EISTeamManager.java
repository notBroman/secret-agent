package jason.eis;

import java.awt.Point;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.logging.Logger;

import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.util.Pair;
import jason.asSyntax.Atom;

public class EISTeamManager {

    private static Logger logger = Logger.getLogger(EISTeamManager.class.getName());


    private static Map<String, String>  agentNames 	 	= new HashMap<String, String>();
	
    private static Map<String, String>  agentAvailable 	 	= new HashMap<String, String>();

    private static Map<Integer, Set<String>> actionsByStep   = new HashMap<Integer, Set<String>>();
	
    private Map<String, Set<Point>>  map1 	 	= new HashMap<String, Set<Point>>();
    private Map<String, Set<Point>>  map2 	 	= new HashMap<String, Set<Point>>();
    private Map<String, Set<Point>>  map3 	 	= new HashMap<String, Set<Point>>();
    private Map<String, Set<Point>>  map4 	 	= new HashMap<String, Set<Point>>();
    private Map<String, Set<Point>>  map5 	 	= new HashMap<String, Set<Point>>();

	
    private Map<String, Map<String, Set<Point>>> agentmaps = new HashMap<String, Map<String, Set<Point>>>();
	
    private int maxPlanners = 5;
    private int planners;
	
    private String firstToStop;
	
    private int pos;
    private String goalAgent;
    private Integer targetGoalX;
    private Integer targetGoalY;
    private String goalSide;
    private List<Point> retrieversAvailablePositions = new ArrayList<>();
	
    private static List<Pair<String, String>> ourBlocks = new ArrayList<>();

    private static class OriginPoint extends Point{
		private String evaluated = "boh";
		private List<Point> scouts = new ArrayList<>();
		private List<Point> retrievers = new ArrayList<>();
		private int maxPosS;
		private int maxPosW;
		private int maxPosE;
		
		public OriginPoint(int x, int y, String evaluated) {
			super(x, y);
			this.evaluated = evaluated;
		}
		
		public OriginPoint(int x, int y, String evaluated, int maxPosS, int maxPosW, int maxPosE) {
			super(x, y);
			this.evaluated = evaluated;
			this.maxPosS = maxPosS;
			this.maxPosW = maxPosW;
			this.maxPosE = maxPosE;
		}
		
	}

    public void init(){
        logger.info("Team Manager has been created!");
        agentmaps.put("agent1",map1);
        agentmaps.put("agent2",map2);
        agentmaps.put("agent3",map3);
        agentmaps.put("agent4",map4);
        agentmaps.put("agent5",map5);

        planners = 0;
        firstToStop = null;
        goalAgent = null;
        targetGoalX = null;
        targetGoalY = null;
        goalSide = null;
        pos  = 10;
    }
    
    public boolean firstToStop(String agent) {
        if (firstToStop == null) {
            firstToStop = agent;
            logger.info("[DEBUG] First agent to stop: " + agent);
            return true;
        }
        return false;
    }


    public boolean callPlanner() {
        if (this.planners + 1 <= this.maxPlanners) {
            this.planners++;
            logger.info("[DEBUG] callPlanner executed: planners now " + this.planners);
            return true;
        }
        logger.info("[DEBUG] callPlanner failed: maxPlanners reached (" + this.maxPlanners + ")");
        return false;
    }

    public void plannerDone() {
        if (this.planners > 0) {
            this.planners--;
            logger.info("[DEBUG] plannerDone executed: planners now " + this.planners);
        } else {
            logger.warning("[DEBUG] plannerDone called, but no active planners.");
        }
    }

    public String joinRetrievers() {
        logger.info("[DEBUG] joinRetrievers called, returning 'retriever'");
        return "retriever";
    }

    public Map<String, Object> getTargetGoal() {
        if (goalAgent == null) {
            logger.warning("[DEBUG] getTargetGoal: No goal set yet.");
            Map<String, Object> emptyGoal = new HashMap<>();
            emptyGoal.put("agent", "none");
            emptyGoal.put("x", -1);
            emptyGoal.put("y", -1);
            emptyGoal.put("side", "none");
            return emptyGoal;
        }

        Map<String, Object> goalData = new HashMap<>();
        goalData.put("agent", goalAgent);
        goalData.put("x", targetGoalX);
        goalData.put("y", targetGoalY);
        goalData.put("side", goalSide);

        logger.info("[DEBUG] getTargetGoal: Returning " + goalData);
        return goalData;
    }

    public void setTargetGoalSide(int pos, String agent, int x, int y, String side) {
        if (pos <= this.pos) { 
            this.goalAgent = agent;
            this.targetGoalX = x;
            this.targetGoalY = y;
            this.pos = pos;
            this.goalSide = side;
            logger.info("[DEBUG] setTargetGoalSide updated: " + agent + " at (" + x + ", " + y + ") with priority " + pos + " on side " + side);
        } else {
            logger.info("[DEBUG] setTargetGoalSide ignored: lower priority " + pos + " vs " + this.pos);
        }
    }

    public void setTargetGoal(int pos, String agent, int x, int y) {
        if (pos <= this.pos) { 
            this.goalAgent = agent;
            this.targetGoalX = x;
            this.targetGoalY = y;
            this.pos = pos;  
            
            logger.info("[DEBUG] setTargetGoal updated: " + agent + " at (" + x + ", " + y + ") with priority " + pos);
        } else {
            logger.info("[DEBUG] setTargetGoal ignored: lower priority " + pos + " vs " + this.pos);
        }
    
    }

    public void updateRetrieverAvailablePos(int x, int y) {
        for (Point p : this.retrieversAvailablePositions) {
            p.x += x;
            p.y += y;
        }
    }
    
    public void initRetrieverAvailablePos(String name) {
		logger.info("initRetrieversAvailablePos");
		if(this.targetGoalX == null | this.targetGoalY == null) return;
		this.retrieversAvailablePositions.clear();
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(targetGoalX == pp.x && targetGoalY == pp.y) {
						logger.info("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
						logger.info(((OriginPoint) pp).retrievers+"");
						for(Point retriever : ((OriginPoint) pp).retrievers) {
							logger.info("[" + name + "]" + "( " + retriever.x + ", " + retriever.y + " ) retriever added");
							this.retrieversAvailablePositions.add(retriever);
						}
						return;
					}
				}
			}
		}
	}
    
    public Map<String, Integer> getRetrieverAvailablePos() {
        logger.info("[DEBUG] Available retriever positions:");
    
        for (Point p : retrieversAvailablePositions) {
            logger.info("( " + p.x + ", " + p.y + " )");
        }
    
        if (!retrieversAvailablePositions.isEmpty()) {
            Point p = retrieversAvailablePositions.remove(0);
            Map<String, Integer> result = new HashMap<>();
            result.put("x", p.x);
            result.put("y", p.y);
            logger.info("[DEBUG] getRetrieverAvailablePos: Returning (" + p.x + ", " + p.y + ")");
            return result;
        }
    
        logger.warning("[WARN] getRetrieverAvailablePos: No retrievers available.");
        return null;
    }

    public void addRetrieverAvailablePos(int x, int y) {
        logger.info("[DEBUG] (" + x + ", " + y + ") is now a retriever available position");
        this.retrieversAvailablePositions.add(new Point(x, y));
    }

    public void addServerName(String agent, String agentServer){
		agentNames.put(agent,agentServer);
	}
	
    public String getServerName(String agent) {
        if (!agentNames.containsKey(agent)) {
            logger.warning("[WARN] getServerName: Agent " + agent + " not found in agentNames.");
            return "unknown";  
        }
    
        String serverName = agentNames.get(agent);
        logger.info("[DEBUG] getServerName: " + agent + " -> " + serverName);
        return serverName;
    }

    public void evaluateOrigin(String name, int x, int y, String evaluation) {
		//if(evaluation.equals("boh")) return;
		logger.info("evaluateOrigin(" + name + ", " + x + ", " + y + ", " + evaluation + ")");
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(x == pp.x && y == pp.y) {
						if(pp instanceof OriginPoint) {
							if(((OriginPoint) pp).evaluated.equals("boh")) {
								((OriginPoint) pp).evaluated = evaluation;
							} 
							return;
						}
						agentmaps.get(name).get(key).remove(pp);
						agentmaps.get(name).get(key).add(new OriginPoint(x, y, evaluation));
						return;
					}
				}
			}
		}
		logger.info("not found it");
	}

    void evaluateOriginMax(String name, int x, int y, String evaluation, int maxPosS, int maxPosW, int maxPosE) {
		//if(evaluation.equals("boh")) return;
		logger.info("evaluateOrigin(" + name + ", " + x + ", " + y + ", " + evaluation + ")");
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(x == pp.x && y == pp.y) {
						if(pp instanceof OriginPoint) {
							if(((OriginPoint) pp).evaluated.equals("boh")) {
								((OriginPoint) pp).evaluated = evaluation;
								((OriginPoint) pp).maxPosS = maxPosS;
								((OriginPoint) pp).maxPosW = maxPosW;
								((OriginPoint) pp).maxPosE = maxPosE;
							} 
							return;
						}
						agentmaps.get(name).get(key).remove(pp);
						agentmaps.get(name).get(key).add(new OriginPoint(x, y, evaluation, maxPosS, maxPosW, maxPosE));
						return;
					}
				}
			}
		}
		logger.info("not found it");
	}

    void addScoutToOrigin(String name, int originX, int originY, int scoutX, int scoutY) {
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(pp instanceof OriginPoint & originX == pp.x && originY == pp.y) {
						((OriginPoint) pp).scouts.add(new Point(scoutX, scoutY));
						return;
					}
				}
			}
		}
	}


    void addRetrieverToOrigin(String name, int originX, int originY, int retrieverX, int retrieverY) {
		for(String key : agentmaps.get(name).keySet()) {
			if(key.startsWith("goal_")) {
				for(Point pp : agentmaps.get(name).get(key)) {
					if(pp instanceof OriginPoint & originX == pp.x && originY == pp.y) {
						logger.info("[" + name + "]" + "(" + retrieverX + ", " + retrieverY + ") retriever added to cluster " + key);
						((OriginPoint) pp).retrievers.add(new Point(retrieverX, retrieverY));
						return;
					}
				}
			}
		}
		logger.info("[" + name + "]" + "addRetrieverToOrigin has not add anything");
	}

    public Map<String, Object> updateGoalMap(String name, int x, int y) {
        Map<String, Object> result = new HashMap<>();
        
        if (!agentmaps.containsKey(name)) {
            logger.warning("[WARN] updateGoalMap: Agent " + name + " not found in agentmaps.");
            result.put("clusterInsertedIn", "none");
            result.put("isANewCluster", false);
            return result;
        }
    
        Point p = new Point(x, y);
        logger.info("[" + name + "]: Try to add goal (" + x + ", " + y + ")");
        double minDistance = 5;
        String myCluster = null;
        int id = 0;
    
        for (String key : agentmaps.get(name).keySet()) {
            if (key.startsWith("goal_")) {
                double distance = 0;
                for (Point pp : agentmaps.get(name).get(key)) {
                    if (p.x == pp.x && p.y == pp.y) {
                        // Goal already exists, do nothing
                        return result; 
                    }
                    distance += Math.abs(p.x - pp.x) + Math.abs(p.y - pp.y);
                }
                distance = distance / agentmaps.get(name).get(key).size();
                if (distance < minDistance) {
                    minDistance = distance;
                    myCluster = key;
                }
                id++;
            }
        }
        // Create new cluster
        if (myCluster == null) { 
            Set<Point> set = new HashSet<>();
            set.add(p);
            agentmaps.get(name).put("goal_" + id, set);
            result.put("clusterInsertedIn", "goal_" + id);
            result.put("isANewCluster", true);
            logger.info("[" + name + "] Added point (" + x + ", " + y + ") to new cluster goal_" + id);
        } 
        // Add to existing cluster
        else { 
            result.put("clusterInsertedIn", myCluster);
            result.put("isANewCluster", false);
            agentmaps.get(name).get(myCluster).add(p);
            logger.info("[" + name + "] Added point (" + x + ", " + y + ") to existing cluster " + myCluster);
        }
    
        return result;
    }

    void updateMap(String name, String type, int x, int y) {
		Point p = new Point(x, y);
		if(!type.startsWith("goal_")) {
			if (!agentmaps.get(name).containsKey(type)) {
				Set<Point> set = new HashSet<Point>();
				set.add(p);
				agentmaps.get(name).put(type, set);
			}
			else {
				agentmaps.get(name).get(type).add(p);
			}
		}
	}
    public int getMapSize(String name) {
        if (!agentmaps.containsKey(name)) {
            logger.warning("[WARN] getMapSize: Agent " + name + " not found in agentmaps.");
            return 0;
        }
    
        int size = agentmaps.get(name).values().stream().mapToInt(Set::size).sum();
        logger.info("[DEBUG] getMapSize(" + name + ") -> " + size);
        return size;
    }

    public List<Map<String, Object>> getGoalClusters(String name) {
        List<Map<String, Object>> clusters = new ArrayList<>();
    
        if (!agentmaps.containsKey(name)) {
            logger.warning("[WARN] getGoalClusters: Agent " + name + " not found in agentmaps.");
            return clusters;
        }
    
        for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
            if (entry.getKey().startsWith("goal_")) {
                Map<String, Object> clusterData = new HashMap<>();
                clusterData.put("clusterName", entry.getKey());
    
                List<Map<String, Object>> goals = new ArrayList<>();
                for (Point p : entry.getValue()) {
                    Map<String, Object> goalData = new HashMap<>();
                    goalData.put("x", p.x);
                    goalData.put("y", p.y);
                    
                    if (p instanceof OriginPoint) {
                        goalData.put("type", "origin");
                        goalData.put("evaluated", ((OriginPoint) p).evaluated);
                    } else {
                        goalData.put("type", "goal");
                    }
                    
                    goals.add(goalData);
                }
    
                clusterData.put("goals", goals);
                clusters.add(clusterData);
            }
        }
    
        logger.info("[DEBUG] getGoalClusters(" + name + ") -> Found " + clusters.size() + " clusters.");
        return clusters;
    }

    public List<Map<String, Object>> getGoalClustersWithScouts(String name) {
        List<Map<String, Object>> clusters = new ArrayList<>();
    
        if (!agentmaps.containsKey(name)) {
            logger.warning("[WARN] getGoalClustersWithScouts: Agent " + name + " not found in agentmaps.");
            return clusters;
        }
    
        for (Map.Entry<String, Set<Point>> entry : agentmaps.get(name).entrySet()) {
            if (entry.getKey().startsWith("goal_")) {
                Map<String, Object> clusterData = new HashMap<>();
                clusterData.put("clusterName", entry.getKey());
    
                List<Map<String, Object>> goals = new ArrayList<>();
                for (Point p : entry.getValue()) {
                    Map<String, Object> goalData = new HashMap<>();
                    goalData.put("x", p.x);
                    goalData.put("y", p.y);
                    
                    if (p instanceof OriginPoint) {
                        goalData.put("type", "origin");
                        goalData.put("evaluated", ((OriginPoint) p).evaluated);
    
                        // Add scouts
                        List<Map<String, Integer>> scoutsList = new ArrayList<>();
                        for (Point scout : ((OriginPoint) p).scouts) {
                            Map<String, Integer> scoutData = new HashMap<>();
                            scoutData.put("x", scout.x);
                            scoutData.put("y", scout.y);
                            scoutsList.add(scoutData);
                        }
                        goalData.put("scouts", scoutsList);
    
                        // Add retrievers
                        List<Map<String, Integer>> retrieversList = new ArrayList<>();
                        for (Point retriever : ((OriginPoint) p).retrievers) {
                            Map<String, Integer> retrieverData = new HashMap<>();
                            retrieverData.put("x", retriever.x);
                            retrieverData.put("y", retriever.y);
                            retrieversList.add(retrieverData);
                        }
                        goalData.put("retrievers", retrieversList);
    
                        // Add max positions
                        goalData.put("maxPosS", ((OriginPoint) p).maxPosS);
                        goalData.put("maxPosW", ((OriginPoint) p).maxPosW);
                        goalData.put("maxPosE", ((OriginPoint) p).maxPosE);
                    } else {
                        goalData.put("type", "goal");
                    }
                    
                    goals.add(goalData);
                }
    
                clusterData.put("goals", goals);
                clusters.add(clusterData);
            }
        }
    
        logger.info("[DEBUG] getGoalClustersWithScouts(" + name + ") -> Found " + clusters.size() + " clusters.");
        return clusters;
    }
    
    public List<Map<String, Object>> getGoals(String name, String cluster) {
        List<Map<String, Object>> goals = new ArrayList<>();
    
        if (!agentmaps.containsKey(name) || !agentmaps.get(name).containsKey(cluster)) {
            logger.warning("[WARN] getGoals: Agent " + name + " or cluster " + cluster + " not found in agentmaps.");
            return goals;
        }
    
        for (Point p : agentmaps.get(name).get(cluster)) {
            Map<String, Object> goalData = new HashMap<>();
            goalData.put("x", p.x);
            goalData.put("y", p.y);
            
            if (p instanceof OriginPoint) {
                goalData.put("type", "origin");
                goalData.put("evaluated", ((OriginPoint) p).evaluated);
            } else {
                goalData.put("type", "goal");
            }
    
            goals.add(goalData);
        }
    
        logger.info("[DEBUG] getGoals(" + name + ", " + cluster + ") -> Found " + goals.size() + " goals.");
        return goals;
    }

    public void addAvailableAgent(String name, String type) {
        agentAvailable.put(name, type);
        logger.info("[DEBUG] addAvailableAgent: " + name + " -> " + type);
    }

    public void removeAvailableAgent(String name) {
		agentAvailable.remove(name);
	}

    public List<Map<String, String>> getAvailableAgent() {
        List<Map<String, String>> availableAgents = new ArrayList<>();
    
        if (agentAvailable.isEmpty()) {
            logger.warning("[WARN] getAvailableAgent: No available agents found.");
            return availableAgents;
        }
    
        for (Map.Entry<String, String> entry : agentAvailable.entrySet()) {
            Map<String, String> agentData = new HashMap<>();
            agentData.put("name", entry.getKey());
            agentData.put("type", entry.getValue());
            availableAgents.add(agentData);
        }
    
        logger.info("[DEBUG] getAvailableAgent -> Found " + availableAgents.size() + " available agents.");
        return availableAgents;
    }

    public String getAvailableMeType(String me) {
        if (!agentAvailable.containsKey(me)) {
            logger.warning("[WARN] getAvailableMeType: Agent " + me + " not found in agentAvailable.");
            return "unknown";  
        }
    
        String type = agentAvailable.get(me);
        logger.info("[DEBUG] getAvailableMeType(" + me + ") -> " + type);
        return type;
    }

    public List<Map<String, String>> getBlocks() {
        List<Map<String, String>> blocks = new ArrayList<>();
    
        if (ourBlocks.isEmpty()) {
            logger.warning("[WARN] getBlocks: No blocks found.");
            return blocks;
        }
    
        for (Pair<String, String> p : ourBlocks) {
            Map<String, String> blockData = new HashMap<>();
            blockData.put("first", p.getFirst());
            blockData.put("second", p.getSecond());
            blocks.add(blockData);
        }
    
        logger.info("[DEBUG] getBlocks -> Found " + blocks.size() + " blocks.");
        return blocks;
    }

    public void addBlock(String ag, String b) {
        ourBlocks.add(new Pair<>(ag, b));
        logger.info("[DEBUG] addBlock: " + ag + " -> " + b);
    }

	public void removeBlock(String ag) {
		ourBlocks.removeIf(p -> p.getFirst().equals(ag));
	}    
    
    void clearTeam() {
		agentNames.clear();
		actionsByStep.clear();
		agentmaps.clear();
		agentAvailable.clear();
		map1.clear();
		map2.clear();
		map3.clear();
		map4.clear();
		map5.clear();
		retrieversAvailablePositions.clear();
		ourBlocks.clear();
		this.init();
	}

    
    public Set<Integer> chosenAction(int step, String agent) {
        Set<Integer> updatedSteps = new HashSet<>();

        // Get or create agent set for this step
        actionsByStep.putIfAbsent(step, new HashSet<>());
        Set<String> agents = actionsByStep.get(step);

        if (!agents.contains(agent)) {
            agents.add(agent);
            // Mark current step for updating
            updatedSteps.add(step); 
        }

        // Remove outdated step (step-3) to maintain last 3 steps
        int oldStep = step - 3;
        if (actionsByStep.containsKey(oldStep)) {
            actionsByStep.remove(oldStep);
            // Mark old step for removal
            updatedSteps.add(oldStep); 
        }

        return updatedSteps;
    }

    public Set<String> getAgentsForStep(int step) {
        // 确保 step 存在，否则返回空集合
        return actionsByStep.getOrDefault(step, new HashSet<>());
    }
    
}
 


