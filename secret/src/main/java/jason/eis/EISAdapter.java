package jason.eis;

import eis.AgentListener;
import eis.EnvironmentInterfaceStandard;
import eis.EnvironmentListener;
import eis.exceptions.*;
import eis.iilang.*;
import jason.JasonException;
import jason.NoValueException;
import jason.asSyntax.*;
import jason.environment.Environment;
import massim.eismassim.EnvironmentInterface;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import jason.eis.EISTeamManager;

/**
 * This class functions as a Jason environment, using EISMASSim to connect to a MASSim server.
 * (see http://cig.in.tu-clausthal.de/eis)
 * (see also https://multiagentcontest.org)
 *
 * @author Jomi
 * - adapted by ta10
 */
public class EISAdapter extends Environment implements AgentListener {

    private Logger logger = Logger.getLogger("EISAdapter." + EISAdapter.class.getName());

    private EnvironmentInterfaceStandard ei;
    // Creating a Team Manager Instance
    private EISTeamManager teamManager;  

    public EISAdapter() {
        super(20);
        // Initialize Team Manager
        teamManager = new EISTeamManager();  
    }

    @Override
    public void init(String[] args) {

        ei = new EnvironmentInterface("conf/eismassimconfig.json");

        try {
            ei.start();
        } catch (ManagementException e) {
            e.printStackTrace();
        }

        ei.attachEnvironmentListener(new EnvironmentListener() {
                public void handleNewEntity(String entity) {}
                public void handleStateChange(EnvironmentState s) {
                    logger.info("new state "+s);
                }
                public void handleDeletedEntity(String arg0, Collection<String> arg1) {}
                public void handleFreeEntity(String arg0, Collection<String> arg1) {}
            });

        for(String e: ei.getEntities()) {
            System.out.println("Register agent " + e);

            try {
                ei.registerAgent(e);
            } catch (AgentException e1) {
                e1.printStackTrace();
            }

            ei.attachAgentListener(e, this);

            try {
                ei.associateEntity(e, e);
            } catch (RelationException e1) {
                e1.printStackTrace();
            }
        }
    }

    @Override
    public void handlePercept(String agent, Percept percept) {}

    @Override
    public List<Literal> getPercepts(String agName) {

        Collection<Literal> ps = super.getPercepts(agName);
        List<Literal> percepts = ps == null? new ArrayList<>() : new ArrayList<>(ps);

        clearPercepts(agName);

        if (ei != null) {
            try {
                Map<String,Collection<Percept>> perMap = ei.getAllPercepts(agName);
                for (String entity: perMap.keySet()) {
                    Structure strcEnt = ASSyntax.createStructure("entity", ASSyntax.createAtom(entity));
                    for (Percept p: perMap.get(entity)) {
                        try {
                            percepts.add(perceptToLiteral(p).addAnnots(strcEnt));
                        } catch (JasonException e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (PerceiveException e) {
                logger.log(Level.WARNING, "Could not perceive.");
            }
        }
        return percepts;
    }

    @Override
    public boolean executeAction(String agName, Structure action) {

        if (ei == null) {
            logger.warning("There is no environment loaded! Ignoring action " + action);
            return false;
        }

        try {
            
            // FirstToStop
            if (action.getFunctor().equals("firstToStop")) {
                String agent = ((Atom) action.getTerm(0)).getFunctor();
                boolean result = teamManager.firstToStop(agent);

                // Feedback to Jason 
                addPercept(agName, ASSyntax.createLiteral("firstToStopResult", ASSyntax.createNumber(result ? 1 : 0)));
                // logger.info("[DEBUG] firstToStop called by " + agent + " result: " + result);
                return true;
            }
            if (action.getFunctor().equals("callPlanner")) {
                boolean result = teamManager.callPlanner();

                // Feedback to Jason 
                addPercept(agName, ASSyntax.createLiteral("plannerResult", ASSyntax.createNumber(result ? 1 : 0)));
                // logger.info("[DEBUG] callPlanner called by " + agName + " result: " + result);
                return true;
            }
            // Handle plannerDone
            if (action.getFunctor().equals("plannerDone")) {
                teamManager.plannerDone();
                // logger.info("[DEBUG] plannerDone called by " + agName);
                return true;
            }
            // Handle joinRetrievers
            if (action.getFunctor().equals("joinRetrievers")) {
                String role = teamManager.joinRetrievers();

                // Return result as a percept to Jason
                addPercept(agName, ASSyntax.createLiteral("retrieverRole", ASSyntax.createString(role)));
                // logger.info("[DEBUG] joinRetrievers called by " + agName + " returning: " + role);
                return true;
            }
            // Handle getTargetGoal
            if (action.getFunctor().equals("getTargetGoal")) {
                Map<String, Object> goalData = teamManager.getTargetGoal();
                if (goalData == null) {
                    return false;
                }

                // Ensure percept is added before Jason queries it
                removePercept(agName, ASSyntax.createLiteral("getTargetGoalResult", ASSyntax.createVar("_"), ASSyntax.createVar("_"), ASSyntax.createVar("_"), ASSyntax.createVar("_")));
                addPercept(agName, ASSyntax.createLiteral("getTargetGoalResult",
                                                          ASSyntax.createString((String) goalData.get("agent")),
                                                          ASSyntax.createNumber((Integer) goalData.get("x")),
                                                          ASSyntax.createNumber((Integer) goalData.get("y")),
                                                          ASSyntax.createString((String) goalData.get("side"))
                                                          ));

                logger.info("[DEBUG] getTargetGoal percept added for " + agName + " -> " + goalData);
                return true;
            }
            // Handle setTargetGoal
            if(action.getFunctor().equals("setTargetGoalSide")) {
                int pos = (int) ((NumberTermImpl) action.getTerm(0)).solve();
                String agent = ((Atom) action.getTerm(1)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(3)).solve();
                String side = ((StringTermImpl) action.getTerm(4)).getString();

                teamManager.setTargetGoalSide(pos, agent, x, y, side);
                logger.info("[DEBUG] setTargetGoal called by " + agent + " for (" + x + ", " + y + ")");
                return true;
            }

            if (action.getFunctor().equals("setTargetGoal")) {
                int pos = (int) ((NumberTermImpl) action.getTerm(0)).solve();
                String agent = ((Atom) action.getTerm(1)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(3)).solve();
    
                teamManager.setTargetGoal(pos, agent, x, y);
                logger.info("[DEBUG] setTargetGoal called by " + agent + " for (" + x + ", " + y + ")");
                return true;
            }

            if (action.getFunctor().equals("updateRetrieverAvailablePos")) {
                int x = (int) ((NumberTermImpl) action.getTerm(0)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(1)).solve();
    
                teamManager.updateRetrieverAvailablePos(x, y);
                logger.info("[DEBUG] updateRetrieverAvailablePos called by " + agName + " with offset (" + x + ", " + y + ")");
                return true;
            }

            if (action.getFunctor().equals("initRetrieverAvailablePos")) {
                String leader = ((Atom) action.getTerm(0)).getFunctor();
    
                teamManager.initRetrieverAvailablePos(leader);
                logger.info("[DEBUG] initRetrieverAvailablePos called by " + agName + " for leader: " + leader);
                return true;
            }

            if (action.getFunctor().equals("getRetrieverAvailablePos")) {
                Map<String, Integer> pos = teamManager.getRetrieverAvailablePos();
                if (pos == null) {
                    logger.warning("[WARN] getRetrieverAvailablePos called but no retrievers available.");
                    return false;
                }
    
                // Send position as percept to Jason agent
                addPercept(agName, ASSyntax.createLiteral("retrieverPosition",
                                                          ASSyntax.createNumber(pos.get("x")),
                                                          ASSyntax.createNumber(pos.get("y"))
                                                          ));
    
                logger.info("[DEBUG] getRetrieverAvailablePos called by " + agName + " -> (" + pos.get("x") + ", " + pos.get("y") + ")");
                return true;
            }
            
            // Handle addRetrieverAvailablePos action
            if (action.getFunctor().equals("addRetrieverAvailablePos")) {
                int x = (int) ((NumberTermImpl) action.getTerm(0)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(1)).solve();

                teamManager.addRetrieverAvailablePos(x, y);
                logger.info("[DEBUG] addRetrieverAvailablePos called by " + agName + " for position (" + x + ", " + y + ")");
                return true;
            }

            // Handle addServerName action
            if (action.getFunctor().equals("addServerName")) {
                String agent, agentServer;
                
                agent = ((Atom) action.getTerm(0)).getFunctor();
                agentServer = ((StringTerm) action.getTerm(1)).getString();
     
            
                teamManager.addServerName(agent, agentServer);
                logger.info("[DEBUG] addServerName 被 " + agName + " 调用 -> " + agentServer);
                return true;
            }

            if (action.getFunctor().equals("getServerName")) {
                String agent = ((Atom) action.getTerm(0)).getFunctor();
                String serverName = teamManager.getServerName(agent);
    
                // Return the result as a percept for Jason agent
                addPercept(agName, ASSyntax.createLiteral("serverNameResult",
                                                          ASSyntax.createString(agent),
                                                          ASSyntax.createString(serverName)
                                                          ));
    
                logger.info("[DEBUG] getServerName called by " + agName + " -> " + serverName);
                return true;
            }

            // Handle evaluateOrigin action
            if (action.getFunctor().equals("evaluateOrigin")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(1)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                String evaluation = ((Atom) action.getTerm(3)).getFunctor();

                teamManager.evaluateOrigin(name, x, y, evaluation);
                logger.info("[DEBUG] evaluateOrigin called by " + agName + " for (" + x + ", " + y + ") -> " + evaluation);
                return true;
            }

            if (action.getFunctor().equals("evaluateOriginMax")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(1)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                String evaluation = ((Atom) action.getTerm(3)).getFunctor();
                int maxPosS = (int) ((NumberTermImpl) action.getTerm(4)).solve();
                int maxPosW = (int) ((NumberTermImpl) action.getTerm(5)).solve();
                int maxPosE = (int) ((NumberTermImpl) action.getTerm(6)).solve();
    
                teamManager.evaluateOriginMax(name, x, y, evaluation, maxPosS, maxPosW, maxPosE);
                logger.info("[DEBUG] evaluateOrigin called by " + agName + " for (" + x + ", " + y + ") -> " + evaluation);
                return true;
            }
            

            // Handle addScoutToOrigin action
            if (action.getFunctor().equals("addScoutToOrigin")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int originX = (int) ((NumberTermImpl) action.getTerm(1)).solve();
                int originY = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                int scoutX = (int) ((NumberTermImpl) action.getTerm(3)).solve();
                int scoutY = (int) ((NumberTermImpl) action.getTerm(4)).solve();

                teamManager.addScoutToOrigin(name, originX, originY, scoutX, scoutY);
                logger.info("[DEBUG] addScoutToOrigin called by " + agName + " for origin (" + originX + ", " + originY + 
                            ") -> scout (" + scoutX + ", " + scoutY + ")");
                return true;
            }

            // Handle addRetrieverToOrigin action
            if (action.getFunctor().equals("addRetrieverToOrigin")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int originX = (int) ((NumberTermImpl) action.getTerm(1)).solve();
                int originY = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                int retrieverX = (int) ((NumberTermImpl) action.getTerm(3)).solve();
                int retrieverY = (int) ((NumberTermImpl) action.getTerm(4)).solve();

                teamManager.addRetrieverToOrigin(name, originX, originY, retrieverX, retrieverY);
                logger.info("[DEBUG] addRetrieverToOrigin called by " + agName + " for origin (" + originX + ", " + originY + 
                            ") -> retriever (" + retrieverX + ", " + retrieverY + ")");
                return true;
            }

            // Handle updateGoalMap action
            if (action.getFunctor().equals("updateGoalMap")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(1)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(2)).solve();

                Map<String, Object> result = teamManager.updateGoalMap(name, x, y);
                String clusterInsertedIn = (String) result.get("clusterInsertedIn");
                boolean isANewCluster = (boolean) result.get("isANewCluster");

                // Send result as a percept to Jason agent
                addPercept(agName, ASSyntax.createLiteral("goalMapUpdate",
                                                          ASSyntax.createString(clusterInsertedIn),
                                                          ASSyntax.createNumber(isANewCluster ? 1 : 0)
                                                          ));

                logger.info("[DEBUG] updateGoalMap called by " + agName + 
                            " -> Cluster: " + clusterInsertedIn + ", NewCluster: " + isANewCluster);
                return true;
            }

            // Handle updateMap action
            if (action.getFunctor().equals("updateMap")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                String type = ((Atom) action.getTerm(1)).getFunctor();
                int x = (int) ((NumberTermImpl) action.getTerm(2)).solve();
                int y = (int) ((NumberTermImpl) action.getTerm(3)).solve();

                teamManager.updateMap(name, type, x, y);
                logger.info("[DEBUG] updateMap called by " + agName + " for (" + x + ", " + y + ") in type: " + type);
                return true;
            }
            // Handle getMapSize action
            if (action.getFunctor().equals("getMapSize")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                int size = teamManager.getMapSize(name);

                // Send result as a percept to Jason agent
                addPercept(agName, ASSyntax.createLiteral("mapSizeResult",
                                                          ASSyntax.createNumber(size)
                                                          ));

                logger.info("[DEBUG] getMapSize called by " + agName + " -> " + size);
                return true;
            }

            // Handle getGoalClusters action
            if (action.getFunctor().equals("getGoalClusters")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                List<Map<String, Object>> clusters = teamManager.getGoalClusters(name);
                
                // Convert goal clusters to a Jason percept
                for (Map<String, Object> cluster : clusters) {
                    String clusterName = (String) cluster.get("clusterName");
                    List<Map<String, Object>> goals = (List<Map<String, Object>>) cluster.get("goals");

                    ListTerm goalList = new ListTermImpl();
                    for (Map<String, Object> goal : goals) {
                        Literal goalLiteral = ASSyntax.createLiteral((String) goal.get("type"),
                                                                     ASSyntax.createNumber((Integer) goal.get("x")),
                                                                     ASSyntax.createNumber((Integer) goal.get("y"))
                                                                     );

                        if (goal.get("type").equals("origin")) {
                            goalLiteral.addTerm(ASSyntax.createAtom((String) goal.get("evaluated")));
                        }
                        
                        goalList.add(goalLiteral);
                    }

                    addPercept(agName, ASSyntax.createLiteral("goalCluster",
                                                              ASSyntax.createString(clusterName),
                                                              goalList
                                                              ));
                }

                logger.info("[DEBUG] getGoalClusters called by " + agName + " -> " + clusters.size() + " clusters.");
                return true;
            }

            // Handle getGoalClustersWithScouts action
            if (action.getFunctor().equals("getGoalClustersWithScouts")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                List<Map<String, Object>> clusters = teamManager.getGoalClustersWithScouts(name);
            
                // Convert goal clusters to a Jason percept
                for (Map<String, Object> cluster : clusters) {
                    String clusterName = (String) cluster.get("clusterName");
                    List<Map<String, Object>> goals = (List<Map<String, Object>>) cluster.get("goals");

                    ListTerm goalList = new ListTermImpl();
                    for (Map<String, Object> goal : goals) {
                        Literal goalLiteral = ASSyntax.createLiteral((String) goal.get("type"),
                                                                     ASSyntax.createNumber((Integer) goal.get("x")),
                                                                     ASSyntax.createNumber((Integer) goal.get("y"))
                                                                     );

                        if ("origin".equals(goal.get("type"))) {
                            goalLiteral.addTerm(ASSyntax.createAtom((String) goal.get("evaluated")));

                            // Add scouts
                            ListTerm scoutsList = new ListTermImpl();
                            for (Map<String, Integer> scout : (List<Map<String, Integer>>) goal.get("scouts")) {
                                Literal scoutLiteral = ASSyntax.createLiteral("scout",
                                                                              ASSyntax.createNumber(scout.get("x")),
                                                                              ASSyntax.createNumber(scout.get("y"))
                                                                              );
                                scoutsList.add(scoutLiteral);
                            }
                            goalLiteral.addTerm(scoutsList);

                            // Add retrievers
                            ListTerm retrieversList = new ListTermImpl();
                            for (Map<String, Integer> retriever : (List<Map<String, Integer>>) goal.get("retrievers")) {
                                Literal retrieverLiteral = ASSyntax.createLiteral("retriever",
                                                                                  ASSyntax.createNumber(retriever.get("x")),
                                                                                  ASSyntax.createNumber(retriever.get("y"))
                                                                                  );
                                retrieversList.add(retrieverLiteral);
                            }
                            goalLiteral.addTerm(retrieversList);

                            // Add max positions
                            goalLiteral.addTerm(ASSyntax.createNumber((Integer) goal.get("maxPosS")));
                            goalLiteral.addTerm(ASSyntax.createNumber((Integer) goal.get("maxPosW")));
                            goalLiteral.addTerm(ASSyntax.createNumber((Integer) goal.get("maxPosE")));
                        }
                    
                        goalList.add(goalLiteral);
                    }

                    addPercept(agName, ASSyntax.createLiteral("goalClusterWithScouts",
                                                              ASSyntax.createString(clusterName),
                                                              goalList
                                                              ));
                }

                logger.info("[DEBUG] getGoalClustersWithScouts called by " + agName + " -> " + clusters.size() + " clusters.");
                return true;
            }

            // Handle getGoals action
            if (action.getFunctor().equals("getGoals")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                String cluster = ((Atom) action.getTerm(1)).getFunctor();
                List<Map<String, Object>> goals = teamManager.getGoals(name, cluster);
            
                // Convert goals to a Jason percept
                ListTerm goalList = new ListTermImpl();
                for (Map<String, Object> goal : goals) {
                    Literal goalLiteral = ASSyntax.createLiteral((String) goal.get("type"),
                                                                 ASSyntax.createNumber((Integer) goal.get("x")),
                                                                 ASSyntax.createNumber((Integer) goal.get("y"))
                                                                 );

                    if ("origin".equals(goal.get("type"))) {
                        goalLiteral.addTerm(ASSyntax.createAtom((String) goal.get("evaluated")));
                    }
                
                    goalList.add(goalLiteral);
                }

                addPercept(agName, ASSyntax.createLiteral("goalList",
                                                          ASSyntax.createString(cluster),
                                                          goalList
                                                          ));

                logger.info("[DEBUG] getGoals called by " + agName + " -> " + goals.size() + " goals.");
                return true;
            }

            // Handle addAvailableAgent action
            if (action.getFunctor().equals("addAvailableAgent")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();
                String type = ((Atom) action.getTerm(1)).getFunctor();

                teamManager.addAvailableAgent(name, type);
                logger.info("[DEBUG] addAvailableAgent called by " + agName + " -> " + type);
                return true;
            }

            // Handle removeAvailableAgent action
            if (action.getFunctor().equals("removeAvailableAgent")) {
                String name = ((Atom) action.getTerm(0)).getFunctor();

                teamManager.removeAvailableAgent(name);
                logger.info("[DEBUG] removeAvailableAgent called by " + agName);
                return true;
            }

            // Handle getAvailableAgent action
            if (action.getFunctor().equals("getAvailableAgent")) {
                List<Map<String, String>> agents = teamManager.getAvailableAgent();
                
                // Convert available agents to a Jason percept
                ListTerm agentList = new ListTermImpl();
                for (Map<String, String> agent : agents) {
                    Literal agentLiteral = ASSyntax.createLiteral("agent",
                        ASSyntax.createAtom(agent.get("name")),
                        ASSyntax.createAtom(agent.get("type"))
                    );
                    agentList.add(agentLiteral);
                }

                addPercept(agName, ASSyntax.createLiteral("availableAgents", agentList));

                logger.info("[DEBUG] getAvailableAgent called by " + agName + " -> " + agents.size() + " agents.");
                return true;
            }

            // Handle getAvailableMeType action
            if (action.getFunctor().equals("getAvailableMeType")) {
                String me = ((Atom) action.getTerm(0)).getFunctor();
                String type = teamManager.getAvailableMeType(me);

                // Send result as a percept to Jason agent
                addPercept(agName, ASSyntax.createLiteral("availableMeType",
                    ASSyntax.createString(me),
                    ASSyntax.createString(type)
                ));

                logger.info("[DEBUG] getAvailableMeType called by " + agName + " -> " + type);
                return true;
            }

            // Handle getBlocks action
            if (action.getFunctor().equals("getBlocks")) {
                List<Map<String, String>> blocks = teamManager.getBlocks();
                
                // Convert blocks to a Jason percept
                ListTerm blockList = new ListTermImpl();
                for (Map<String, String> block : blocks) {
                    Literal blockLiteral = ASSyntax.createLiteral("block",
                        ASSyntax.createAtom(block.get("first")),
                        ASSyntax.createAtom(block.get("second"))
                    );
                    blockList.add(blockLiteral);
                }

                addPercept(agName, ASSyntax.createLiteral("blocks", blockList));

                logger.info("[DEBUG] getBlocks called by " + agName + " -> " + blocks.size() + " blocks.");
                return true;
            }

            // Handle addBlock action
            if (action.getFunctor().equals("addBlock")) {
                String ag = ((Atom) action.getTerm(0)).getFunctor();
                String b = ((Atom) action.getTerm(1)).getFunctor();

                teamManager.addBlock(ag, b);
                logger.info("[DEBUG] addBlock called by " + agName + " -> " + b);
                return true;
            }

            // Handle removeBlock action
            if (action.getFunctor().equals("removeBlock")) {
                String ag = ((Atom) action.getTerm(0)).getFunctor();

                teamManager.removeBlock(ag);
                logger.info("[DEBUG] removeBlock called by " + agName);
                return true;
            }

            // Handle clearTeam action
            if (action.getFunctor().equals("clearTeam")) {
                teamManager.clearTeam();
                logger.info("[DEBUG] clearTeam called by " + agName);
                return true;
            }

            if (action.getFunctor().equals("chosenAction")) {
                int step = (int) ((NumberTermImpl) action.getTerm(0)).solve();
    
                // Call teamManager.chosenAction and get the step that needs to be updated
                Set<Integer> updatedSteps = teamManager.chosenAction(step, agName);
                logger.info("[DEBUG] chosenAction  " + agName + "  step = " + step);
    
                // Traverse all steps that need to be updated and perform differentiated processing
                for (int updatedStep : updatedSteps) {
                    Set<String> agents = teamManager.getAgentsForStep(updatedStep);
                    ListTerm agentList = new ListTermImpl();
                
                    for (String agent : agents) {
                        agentList.add(ASSyntax.createAtom(agent));
                    }
                
                    if (updatedStep == step) {
                        // For the current step, delete the old belief first and then add the new belief to prevent data duplication.
                        removePercept(agName, ASSyntax.createLiteral("chosenActions", ASSyntax.createNumber(updatedStep), agentList));
                        addPercept(agName, ASSyntax.createLiteral("chosenActions", ASSyntax.createNumber(updatedStep), agentList));
                        logger.info("[DEBUG] 添加 belief: chosenActions(" + updatedStep + ", " + agents + ")");
                    } else if (updatedStep == step - 3 && updatedStep > 0) {
                        // Only delete step-3 to ensure that Jason belief data does not grow infinitely and does not affect step 0
                        removePercept(agName, ASSyntax.createLiteral("chosenActions", ASSyntax.createNumber(updatedStep), agentList));
                        logger.info("[DEBUG] 移除 belief: chosenActions(" + updatedStep + ")");
                    }
                }
    
                return true;
            }


            logger.info("[DEBUG] Agent: " + agName + " is attempting to perform action: " + action);
            Action convertedAction = literalToAction(action);
            logger.info("[DEBUG] Converted Action: " + convertedAction);
    
            ei.performAction(agName, literalToAction(action));
            return true;
        } catch (ActException e) {
            e.printStackTrace();
        }

        return false;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        if (ei != null) {
            try {
                if (ei.isKillSupported()) ei.kill();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        super.stop();
    }

    private static Literal perceptToLiteral(Percept per) throws JasonException {
        Literal l = ASSyntax.createLiteral(per.getName());
        for (Parameter par: per.getParameters())
            l.addTerm(parameterToTerm(par));
        return l;
    }

    private static Term parameterToTerm(Parameter par) throws JasonException {
        if (par instanceof Numeral) {
            return ASSyntax.createNumber(((Numeral)par).getValue().doubleValue());
        } else if (par instanceof Identifier) {
            try {
                Identifier i = (Identifier)par;
                String a = i.getValue();
                if (!Character.isUpperCase(a.charAt(0)))
                    return ASSyntax.parseTerm(a);
            } catch (Exception ignored) {}
            return ASSyntax.createString(((Identifier)par).getValue());
        } else if (par instanceof ParameterList) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (Parameter p: (ParameterList)par)
                tail = tail.append( parameterToTerm(p) );
            return list;
        } else if (par instanceof Function) {
            Function f = (Function)par;
            Structure l = ASSyntax.createStructure(f.getName());
            for (Parameter p: f.getParameters())
                l.addTerm(parameterToTerm(p));
            return l;
        }
        throw new JasonException("The type of parameter "+par+" is unknown!");
    }

    private static Action literalToAction(Literal action) {
        Parameter[] pars = new Parameter[action.getArity()];
        for (int i = 0; i < action.getArity(); i++)
            pars[i] = termToParameter(action.getTerm(i));
        return new Action(action.getFunctor(), pars);
    }

    private static Parameter termToParameter(Term t) {
        if (t.isNumeric()) {
            try {
                double d = ((NumberTerm) t).solve();
                if((d == Math.floor(d)) && !Double.isInfinite(d)) return new Numeral((int)d);
                return new Numeral(d);
            } catch(NoValueException e){
                e.printStackTrace();
            }
            return new Numeral(null);
        } else if (t.isList()) {
            Collection<Parameter> terms = new ArrayList<>();
            for (Term listTerm: (ListTerm)t)
                terms.add(termToParameter(listTerm));
            return new ParameterList( terms );
        } else if (t.isString()) {
            return new Identifier( ((StringTerm)t).getString() );
        } else if (t.isLiteral()) {
            Literal l = (Literal)t;
            if (!l.hasTerm()) {
                return new Identifier(l.getFunctor());
            } else {
                Parameter[] terms = new Parameter[l.getArity()];
                for (int i = 0; i < l.getArity(); i++)
                    terms[i] = termToParameter(l.getTerm(i));
                return new Function( l.getFunctor(), terms );
            }
        }
        return new Identifier(t.toString());
    }


}
