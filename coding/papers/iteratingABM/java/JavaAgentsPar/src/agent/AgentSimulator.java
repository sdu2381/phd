package agent;

import java.util.*;
import java.util.concurrent.*;

/**
 * Created by jonathan on 20/01/17.
 */
public class AgentSimulator<A extends Agent, E> {

    private double time;
    private ExecutorService executor;

    public AgentSimulator() {
        executor = Executors.newFixedThreadPool(3);
    }

    public List<A> simulateWithObserver(List<A> as,
                                        Map<Integer, E> globalEnv,
                                        double dt,
                                        ISimulationObserver<A> o) throws InterruptedException, ExecutionException {
        LinkedHashMap<Integer, A> om = createOrderedMap(as);

        Map<Integer, E> unmodifieableGlobalEnv = null;
        if ( null != globalEnv )
            unmodifieableGlobalEnv = Collections.unmodifiableMap( globalEnv );

        while(o.simulationStep(om)) {
            om = this.nextStepSimultaneous(om, globalEnv, unmodifieableGlobalEnv, dt);
        }

        return as;
    }

    private LinkedHashMap<Integer, A> nextStepSimultaneous(LinkedHashMap<Integer, A> om,
                                                           Map<Integer, E> globalEnv,
                                                           Map<Integer, E> unmodifieableGlobalEnv,
                                                           double delta) throws ExecutionException, InterruptedException {
        this.time = this.time + delta;

        List<Future<Void>> agentFutures = new ArrayList<>( om.size() );

        // distribute messages
        Iterator<Map.Entry<Integer, A>> iter = om.entrySet().iterator();
        while ( iter.hasNext() ) {
            Map.Entry<Integer, A> e = iter.next();
            A a = e.getValue();

            Iterator<MsgPair> msgIter = a.getOutBox().iterator();
            while ( msgIter.hasNext() ) {
                MsgPair p = msgIter.next();

                om.get(p.agent.getId()).getInBox().add(new MsgPair(a, p.msg));
            }

            a.getOutBox().clear();
        }

        // start agent-computations
        iter = om.entrySet().iterator();
        while ( iter.hasNext() ) {
            Map.Entry<Integer, A> e = iter.next();
            A a = e.getValue();

            Future<Void> af = executor.submit(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    a.step(time, delta, unmodifieableGlobalEnv);
                    return null;
                }
            });

            agentFutures.add(af);
        }

        // wait for the results
        for (Future<Void> f : agentFutures ) {
            f.get();
        }

        if ( null != globalEnv ) {
            iter = om.entrySet().iterator();
            while (iter.hasNext()) {
                Map.Entry<Integer, A> e = iter.next();
                A a = e.getValue();

                globalEnv.put(a.getId(), (E) a.getLocalEnv());
            }
        }

        return om;
    }

    private LinkedHashMap<Integer, A> createOrderedMap(List<A> as) {
        LinkedHashMap<Integer, A> om = new LinkedHashMap<>();

        for (A a : as) {
            om.put(a.getId(), a);
        }

        return om;
    }
}
