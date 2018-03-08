using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Effects
{
    public class Spin : MonoBehaviour
    {
        [Tooltip("The speed in degrees that this will rotate around each axis")]
        public Vector3 rotationSpeed;

        void Update()
        {
            transform.Rotate(rotationSpeed * Time.deltaTime);
        }
    }
}