using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

#if UNITY_EDITOR && UNITY_IOS

public class CoreHapticPostProcessor
{
    [PostProcessBuild(1)]
    public static void OnPostProcessBuild(BuildTarget target, string pathToProject)
    {
        var projectPath = PBXProject.GetPBXProjectPath(pathToProject);

        var pbxproj = new PBXProject();
        pbxproj.ReadFromFile(projectPath);

        var guid = pbxproj.GetUnityFrameworkTargetGuid();
        pbxproj.AddFrameworkToProject(guid, "CoreHaptics.framework", true);

        pbxproj.WriteToFile(projectPath);
    }
}

#endif
