using UnityEngine;
using System.Collections;

namespace MagicForestRide.Effects
{
    /// <summary>
    /// Always face the camera - either totally or only on the y axis
    /// </summary>
    public class Billboard : MonoBehaviour
    {
        public enum BillboardAxis
        {
            YOnly, Free
        }

        [Tooltip("The range of motion of this billboard effect")]
        public BillboardAxis axis;
   
        void Update()
        {
            if (Camera.main == null)
                return;

            var lookAt = Camera.main.transform.position;

            if(axis == BillboardAxis.YOnly)
            {
                lookAt.y = transform.position.y;
            }

            transform.LookAt(lookAt);
        }
    }
}