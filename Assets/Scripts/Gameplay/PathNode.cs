using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Gameplay
{
    public class PathNode : MonoBehaviour
    {
        private PathNode Next { get; set; }
        private PathNode Previous { get; set; }

        // Use this for initialization
        void Start()
        {
            var renderers = GetComponentsInChildren<Renderer>();
            foreach (var renderer in renderers)
            {
                renderer.enabled = false;
            }
        }

        public PathNode GetNext()
        {
            var nextIndex = transform.GetSiblingIndex() + 1;
            if (transform.parent.childCount <= nextIndex)
                return null;

            return transform.parent.GetChild(nextIndex).GetComponent<PathNode>();
        }
    }
}