using System;
using System.Runtime.InteropServices;
using AOT;
using Newtonsoft.Json;
using UnityEngine;

namespace CoreHapticsUnity
{
	public static class CoreHapticsUnityProxy
	{
		public static LogsLevel LogLevel = LogsLevel.Verbose;
		
		private delegate void HapticStoppedDelegate(int reason);

		public delegate void HapticStoppedReasonDelegate(int stopCode);

		/// <summary>
		/// Event after pattern ends. 0 - Ok; else error code
		/// </summary>
		public static event HapticStoppedReasonDelegate OnHapticStopped;
		
		public static void PlayContinuous(float intensity, float sharpness, float durationInSeconds)
		{
			if (!isSupported) return;
			_coreHapticsUnityPlayContinuous(intensity, sharpness, durationInSeconds);
		}
	
		public static void PlayContinuous()
		{
			PlayContinuous(0.5f, 0.5f, 30f);
		}

		public static void PlayPattern(HapticsPattern pattern)
		{
			if (!isSupported) return;

			var json = JsonConvert.SerializeObject(pattern, Formatting.Indented);
			_coreHapticsUnityplayWithDictionaryPattern(json);
		}

		public static void PlayPattern(string json)
		{
			_coreHapticsUnityplayWithDictionaryPattern(json);
		}
	
		public static void PlayTransient(float intensity, float sharpness)
		{
			if (!isSupported) return;
			_coreHapticsUnityPlayTransient(intensity, sharpness);
		}
	
		public static void PlayTransient()
		{
			PlayTransient(0.5f, 0.5f);
		}

		public static void PlayFromFileWithName(string filename)
		{
			if (!isSupported) return;
			_coreHapticsUnityplayWIthAHAPFile(filename);
		}

		public static void PlayFromFileWithURL(string url)
		{
			if (!isSupported) return;
			_coreHapticsUnityplayWithAHAPFileFromURLAsString(url);
		}

		public static void Stop()
		{
			if (!isSupported) return;
			_coreHapticsUnityStop();
		}

		public static void UpdateContinuousValues(float intensity, float sharpness)
		{
			if (!isSupported) return;
			
			_coreHapticsUnityupdateContinuousHaptics(RoundToDigits(intensity, 3), RoundToDigits(sharpness, 3));
		}

		public static bool IsSupported => isSupported;

		static CoreHapticsUnityProxy()
		{
#if UNITY_EDITOR
			isSupported = true;
			LogLevel = LogsLevel.Verbose;
#else
			isSupported = Application.platform == RuntimePlatform.IPhonePlayer && _coreHapticsUnityIsSupport();
			LogLevel = LogsLevel.None;
#endif
			
			_coreHapticsRegisterCallback(HapticStoppedCallback);
		}

		private static float RoundToDigits(float val, int digits)
		{
			int num = (int)Mathf.Pow(10, digits);
			return Mathf.Round(val * num) / num;
		}

		[MonoPInvokeCallback(typeof(HapticStoppedDelegate))]
		private static void HapticStoppedCallback(int code)
		{
			OnHapticStopped?.Invoke(code);
		}

		private static readonly bool isSupported;
	
		#region DllImport

#if UNITY_IPHONE && !UNITY_EDITOR
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityPlayContinuous(float intensity, float sharpness, float durationInSeconds);
		[DllImport("__Internal")]
        private static extern void _coreHapticsUnityPlayTransient(float intensity, float sharpness);
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityStop();
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityupdateContinuousHaptics(float intensity, float sharpness);
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityplayWithDictionaryPattern(string jsonDict);
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityplayWIthAHAPFile(string filename);
        [DllImport("__Internal")]
        private static extern void _coreHapticsUnityplayWithAHAPFileFromURLAsString(string url);
        [DllImport("__Internal")]
        private static extern bool _coreHapticsUnityIsSupport();
        [DllImport("__Internal")]
        private static extern void _coreHapticsRegisterCallback(HapticStoppedDelegate callback);
#else
		private static void _coreHapticsUnityPlayContinuous(float intensity, float sharpness, float durationInSeconds)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Play Continuous with Intensity: {0} and Sharpness: {1} for {2} seconds", intensity.ToString(), sharpness.ToString(), durationInSeconds.ToString());
		}

		private static void _coreHapticsUnityPlayTransient(float intensity, float sharpness)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Play Transient with Intensity: {0} and Sharpness: {1}", intensity.ToString(), sharpness.ToString());
		}

		private static void _coreHapticsUnityStop()
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Stop");
		}

		private static void _coreHapticsUnityupdateContinuousHaptics(float intensity, float sharpness)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Update Continuous Params with Intensity: {0} and Sharpness: {1}", intensity.ToString(), sharpness.ToString());
		}

		private static void _coreHapticsUnityplayWithDictionaryPattern(string jsonDict)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Play from Pattern: {0}", jsonDict);
		}

		private static void _coreHapticsUnityplayWIthAHAPFile(string filename)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Play from File with Name: {0}", filename);
		}

		private static void _coreHapticsUnityplayWithAHAPFileFromURLAsString(string url)
		{
			if (LogLevel > LogsLevel.None)
				Debug.LogFormat("[CoreHapticsUnity] Play from File by URL: {0}", url);
		}

		private static bool _coreHapticsUnityIsSupport()
		{
			return false;
		}
		
		private static void _coreHapticsRegisterCallback(HapticStoppedDelegate callback)
		{
		}
#endif

		#endregion // DllImport
	}

	public enum LogsLevel
	{
		None,
		Verbose
	}
}
