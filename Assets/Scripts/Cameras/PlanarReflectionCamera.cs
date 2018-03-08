using UnityEngine;
using System.Collections;

namespace MagicForestRide.Cameras
{
    /// <summary>
    /// Follows the main camera to produce a reflection effect
    /// </summary>
    [ExecuteInEditMode]
    public class PlanarReflectionCamera : MonoBehaviour
    {
        private const string reflectionCameraToWorldId = "_ReflectionCameraToWorld";

        [Tooltip("The camera that should be mirrored in this planar surface")]
        public Camera cameraToMirror;

        [Tooltip("The material with a shader that requires projection to this camera")]
        public Material material;

        private Camera cameraRef;
        private Transform parentTransform;

        private Matrix4x4 reflectionMatrix;

        void Awake()
        {
            cameraRef = GetComponent<Camera>();
            parentTransform = transform.parent;
        }

        void OnPreRender()
        {
            if (cameraToMirror == null)
                return;

            float d = -Vector3.Dot(Vector3.up, parentTransform.position);
            CalculateReflectionMatrix(new Vector4(0f, 1f, 0f, d));

            cameraRef.worldToCameraMatrix = cameraToMirror.worldToCameraMatrix * reflectionMatrix;
            cameraRef.projectionMatrix = cameraToMirror.projectionMatrix;

            //Update the matrix in the shader
            material.SetMatrix("_ReflectionCameraToWorld", cameraRef.projectionMatrix * cameraRef.worldToCameraMatrix);
        }

        private void CalculateReflectionMatrix(Vector4 plane)
        {
            reflectionMatrix.m00 = (1.0f - 2f * plane[0] * plane[0]);
            reflectionMatrix.m01 = (-2f * plane[0] * plane[1]);
            reflectionMatrix.m02 = (-2f * plane[0] * plane[2]);
            reflectionMatrix.m03 = (-2f * plane[3] * plane[0]);

            reflectionMatrix.m10 = (-2f * plane[1] * plane[0]);
            reflectionMatrix.m11 = (1.0f - 2f * plane[1] * plane[1]);
            reflectionMatrix.m12 = (-2f * plane[1] * plane[2]);
            reflectionMatrix.m13 = (-2f * plane[3] * plane[1]);

            reflectionMatrix.m20 = (-2f * plane[2] * plane[0]);
            reflectionMatrix.m21 = (-2f * plane[2] * plane[1]);
            reflectionMatrix.m22 = (1.0f - 2f * plane[2] * plane[2]);
            reflectionMatrix.m23 = (-2f * plane[3] * plane[2]);

            reflectionMatrix.m30 = 0.0f;
            reflectionMatrix.m31 = 0.0f;
            reflectionMatrix.m32 = 0.0f;
            reflectionMatrix.m33 = 1.0f;
        }
    }
}