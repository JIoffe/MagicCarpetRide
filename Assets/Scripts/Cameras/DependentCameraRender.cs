using UnityEngine;
using System.Collections;

namespace MagicForestRide.Cameras
{
    /// <summary>
    /// Will invoke the dependent camera to render before rendering the active camera
    /// </summary>
    public class DependentCameraRender : MonoBehaviour
    {
        public Camera dependentCamera;

        private Terrain terrain;

        void Start()
        {
            terrain = GameObject.FindObjectOfType<Terrain>();
        }
        void OnPreRender()
        {
            if (dependentCamera == null)
                return;

            GL.invertCulling = true;
            var d = terrain.detailObjectDistance;
            terrain.detailObjectDistance = 0;
            dependentCamera.Render();
            terrain.detailObjectDistance = d;
            GL.invertCulling = false;
        }
    }
}