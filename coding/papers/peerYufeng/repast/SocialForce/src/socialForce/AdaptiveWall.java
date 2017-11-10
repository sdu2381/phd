package socialForce;

import java.util.List;

import repast.simphony.engine.schedule.ScheduledMethod;

public class AdaptiveWall {
	
	public double x = 300;
	public double y = 250;
	
	public double min = 250;
	public double max = 400;
	
	public double totalWidth = 300;
	
	public double door0x = 75;
	public double door1x = 425;
	
	public double sumFijV;
	public double sumFijH;
	
	public List<Double> doorsX; // TODO: add door0x and door1x
	
	public double speed = 0;
	
	public final static double Ai = 5;
	public final static double Bi = 5;
	public final static double AiS = 200;
	public final static double BiS = 0.1;
	public final static double K = 1.2*10;
	
	// TODO: cyclic event, first occurence t=0, then every UNIT_TIME seconds
	@ScheduledMethod(start = 0, interval = SocialForce.UNIT_TIME)
	public void action() {
		socialForce();
		double acceH = (sumFijH);
		double tspeed = speed + acceH*SocialForce.UNIT_TIME;
		//System.out.println(acceV);
		if(tspeed>-0.1 && tspeed <0.1){
			speed = tspeed;
		}
		double tx = x + (speed*SocialForce.UNIT_TIME)*SocialForce.METER_2_PX;
		if(tx>min && tx<max){
			x=tx;
		}

		/*
		double acceV = (sumFijV);
		double tspeed = speed + acceV*unitTime;
		//System.out.println(acceV);
		if(tspeed>-0.1 && tspeed <0.1){
			speed = tspeed;
		}
		double ty = y + (speed*unitTime)*get_Main().meter2px;
		if(ty>ymin && ty<ymax){
			y=ty;
		}
		*/
	}
	
	public void socialForce() {
		sumFijH = 0;
		for(Person j : get_Main().people){
			//if(!j.inState(j.reading) && !j.inState(j.moving)){continue;}
			double ax = x/SocialForce.METER_2_PX;
			double ay = y/SocialForce.METER_2_PX;
			double dij = -1;
			dij = Math.abs(ax-j.x);
			double nij1,nij2;
			double rij,gx;
			double fpsy;
			double fijH,fijV;
			rij = j.ri;

			nij1 = (ax-j.x)/dij;
			fpsy = Ai*Math.exp((rij-dij)/Bi);

			fijH = (fpsy)*nij1;
			sumFijH += fijH;
		}
		/*sumFijV = 0;
		for(Person j : get_Main().people){
			//if(!j.inState(j.reading) && !j.inState(j.moving)){continue;}
			double ax = x/get_Main().meter2px;
			double ay = y/get_Main().meter2px;
			double dij = -1;
			dij = Math.abs(ay-j.y);
			double nij1,nij2;
			double rij,gx;
			double fpsy;
			double fijH,fijV;
			rij = j.ri;

			nij2 = (ay-j.y)/dij;
			fpsy = Ai*exp((rij-dij)/Bi);

			fijV = (fpsy)*nij2;
			sumFijV += fijV;
		}
		*/
	}
	
	public double getNearestPoint(double x1, double y1, Point p) {
		return Utils.sqr(x1 - this.x);
	}
}
