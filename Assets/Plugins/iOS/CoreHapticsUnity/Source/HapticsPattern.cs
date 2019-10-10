using System;
using System.Collections.Generic;
using UnityEngine;

namespace CoreHapticsUnity
{
	[Serializable]
	public class HapticsPattern
	{
		[SerializeField]
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

	[Serializable]
	public class HapticEvent : IEvent
	{
		[SerializeField]
		public Event Event;

		public HapticEvent(float time, EventType eventType, EventParameter[] parameters, float duration = 0f)
		{
			Event = new Event(time, eventType, parameters, duration);
		}
	}
	
	[Serializable]
	public class HapticParameterCurve : IEvent
	{
		[SerializeField]
		public ParameterCurve ParameterCurve;

		public HapticParameterCurve(float time, ParameterIDType id, ParameterCurveControlPoint[] points)
		{
			ParameterCurve = new ParameterCurve(time, id, points);
		}
	}
	
	[Serializable]
	public class Event
	{
		[SerializeField]
		public float Time;

		[SerializeField]
		public string EventType;

		[SerializeField]
		public float EventDuration;

		[SerializeField]
		public EventParameter[] EventParameters;

		public Event(float time, EventType eventType, EventParameter[] parameters, float duration = 0f)
		{
			Time = time;
			EventType = eventType.ToString();
			EventDuration = duration;
			EventParameters = parameters;
		}
	}

	[Serializable]
	public class ParameterCurve
	{

		[SerializeField]
		public string ParameterID;

		[SerializeField]
		public float Time;

		[SerializeField]
		public ParameterCurveControlPoint[] ParameterCurveControlPoints;

		public ParameterCurve(float time, ParameterIDType id, ParameterCurveControlPoint[] points)
		{
			Time = time;
			ParameterID = id.ToString();
			ParameterCurveControlPoints = points;
		}
	}

	[Serializable]
	public class EventParameter
	{
		[SerializeField] 
		public string ParameterID;

		[SerializeField]
		public float ParameterValue;

		public EventParameter(HapticsType id, float value)
		{
			ParameterID = id.ToString();
			ParameterValue = value;
		}
	}

	[Serializable]
	public class ParameterCurveControlPoint
	{
		[SerializeField] 
		public float Time;

		[SerializeField]
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
