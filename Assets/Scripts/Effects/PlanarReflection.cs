using UnityEngine;
using MagicForestRide.Cameras;
using System.Collections;

namespace MagicForestRide.Effects
{
    /// <summary>
    /// Intended for planar surfaces that display reflections from the main camera. Will automatically
    /// create and activate two mirror cameras if the main camera is split in stereo
    /// </summary>
    public class PlanarReflection : MonoBehaviour
    {
        [Tooltip("The layers that will be captured in the reflection")]
        public LayerMask cullingMask;

        [Tooltip("The render target to use for the rendering of this planar reflection")]
        public RenderTexture reflectionTexture;

        /// <summary>
        ///  Initialize the cameras necessary to simulate a mirror effect
        /// </summary>
        void Start()
        {
            if (Camera.main == null)
                return;

            //Google VR might take too long to configure, so we need to wait for it
            StartCoroutine(WaitForVRCameras());
        }

        IEnumerator WaitForVRCameras()
        {
            var waitTime = 0f;
            var material = GetPrimaryMaterial();

            while (waitTime <= 10f && Camera.main.transform.childCount <= 1)
            {
                waitTime += Time.deltaTime;
                yield return null;
            }

            if(Camera.main.transform.childCount <= 1)
            {
                CreateReflectionCamera(Camera.main, material);
            }else
            {
                var cameras = Camera.main.GetComponentsInChildren<Camera>();
                foreach (Camera camera in cameras)
                {
                    if (camera != Camera.main)
                    {
                        CreateReflectionCamera(camera, material);

                        //While we're here, allow the VR camera to see flares
                        camera.gameObject.AddComponent<FlareLayer>();
                    }
                }
            }
        }
        private Material GetPrimaryMaterial()
        {
            var renderer = GetComponentInChildren<Renderer>();
            return renderer.material;
        }
        private void CreateReflectionCamera(Camera cameraToMirror, Material material)
        {
            var reflectionCameraObject = new GameObject("Reflection Camera");
            reflectionCameraObject.transform.SetParent(transform);

            var reflectionCamera = reflectionCameraObject.AddComponent<Camera>();
            reflectionCamera.cullingMask = cullingMask;
            reflectionCamera.targetTexture = reflectionTexture;

            //Render will be invoked manually
            reflectionCamera.enabled = false;

            var planarReflectionCamera = reflectionCameraObject.AddComponent<PlanarReflectionCamera>();
            planarReflectionCamera.cameraToMirror = cameraToMirror;
            planarReflectionCamera.material = material;

            //Sync up the cameras - when one is about to render, render the appropriate reflection
            var dependentCameraRender = cameraToMirror.gameObject.AddComponent<DependentCameraRender>();
            dependentCameraRender.dependentCamera = reflectionCamera;
        }
    }
}