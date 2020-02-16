using System;
using System.Collections.Generic;
using UnityEngine;

namespace CoreHapticsUnity
{
	public class HapticsPattern
	{
		public List<IEvent> Pattern;

		public HapticsPattern(IEnumerable<IEvent> events)
		{
			Pattern = new List<IEvent>(events);
		}
		
		public HapticsPattern(int capacity)
		{
			Pattern = new List<IEvent>(capacity);
		}
		
		public void AddEvent(IEvent _event)
		{
			if (Pattern == null) Pattern = new List<IEvent>();
			
			Pattern.Add(_event);
		}
	}

	public class HapticEvent : IEvent
	{
		public Event Event;

		public HapticEvent(float time, EventType eventType, EventParameter[] parameters, float duration = 0f)
		{
			Event = new Event(time, eventType, parameters, duration);
		}
	}
	
	public class HapticParameterCurve : IEvent
	{
		public ParameterCurve ParameterCurve;

		public HapticParameterCurve(float time, ParameterIDType id, ParameterCurveControlPoint[] points)
		{
			ParameterCurve = new ParameterCurve(time, id, points);
		}
	}
	
	public class Event
	{
		public float Time;

		public string EventType;

		public float EventDuration;

		public EventParameter[] EventParameters;

		public Event(float time, EventType eventType, EventParameter[] parameters, float duration = 0f)
		{
			Time = time;
			EventType = eventType.ToString();
			EventDuration = duration;
			EventParameters = parameters;
		}
	}

	public class ParameterCurve
	{

		public string ParameterID;

		public float Time;

		public ParameterCurveControlPoint[] ParameterCurveControlPoints;

		public ParameterCurve(float time, ParameterIDType id, ParameterCurveControlPoint[] points)
		{
			Time = time;
			ParameterID = id.ToString();
			ParameterCurveControlPoints = points;
		}
	}

	public class EventParameter
	{
		public string ParameterID;

		public float ParameterValue;

		public EventParameter(HapticsType id, float value)
		{
			ParameterID = id.ToString();
			ParameterValue = value;
		}
	}

	public class ParameterCurveControlPoint
	{
		public float Time;

		public float ParameterValue;

		public ParameterCurveControlPoint(float time, float value)
		{
			Time = time;
			ParameterValue = value;
		}
	}

	public interface IEvent
	{
	}

	public enum EventType
	{
		HapticTransient,
		HapticContinuous
	}

	public enum ParameterIDType
	{
		HapticIntensityControl,
		HapticSharpnessControl
	}

	public enum HapticsType
	{
		HapticIntensity,
		HapticSharpness
	}
}
