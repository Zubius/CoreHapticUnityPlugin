using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using UnityEngine;

namespace CoreHapticsUnity
{
	public class HapticsPattern
	{
		[JsonProperty("Pattern")]
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
		[JsonProperty("Event")]
		public Event Event;

		public HapticEvent(float time, EventType eventType, EventParameter[] parameters, float duration = 0f)
		{
			Event = new Event(time, eventType, parameters, duration);
		}
	}
	
	[JsonObject(MemberSerialization.OptIn)]
	public class HapticParameterCurve : IEvent
	{
		[JsonProperty("ParameterCurve")]
		public ParameterCurve ParameterCurve;

		public HapticParameterCurve(float time, ParameterIDType id, ParameterCurveControlPoint[] points)
		{
			ParameterCurve = new ParameterCurve(time, id, points);
		}
	}
	
	public class Event
	{
		[JsonProperty("Time")]
		public float Time;

		[JsonProperty("EventType")]
		public string EventType;

		[JsonProperty("EventDuration")]
		public float EventDuration;

		[JsonProperty("EventParameters")]
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
		[JsonProperty("ParameterID")]
		public string ParameterID;

		[JsonProperty("Time")]
		public float Time;

		[JsonProperty("ParameterCurveControlPoints")]
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
		[JsonProperty("ParameterID")]
		public string ParameterID;

		[JsonProperty("ParameterValue")]
		public float ParameterValue;

		public EventParameter(HapticsType id, float value)
		{
			ParameterID = id.ToString();
			ParameterValue = value;
		}
	}

	public class ParameterCurveControlPoint
	{
		[JsonProperty("Time")]
		public float Time;

		[JsonProperty("ParameterValue")]
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
