using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Gameplay
{
    public class PathFollower : MonoBehaviour
    {
        [Tooltip("Speed in meters/second")]
        public float movementSpeed = 0.5f;


        [Tooltip("The node at the beginning of the path")]
        public PathNode startingPathNode;

        private PathNode currentPathNode;
        // Use this for initialization
        void Start()
        {
            currentPathNode = startingPathNode;
        }

        // Update is called once per frame
        void Update()
        {
            if (currentPathNode == null)
                return;

            var nodeDirection = (currentPathNode.transform.position - transform.position).normalized;

            transform.forward = Vector3.Lerp(transform.forward, nodeDirection, 0.5f * Time.deltaTime);
            transform.position = transform.position + nodeDirection * movementSpeed * Time.deltaTime;

            if (Vector3.Distance(transform.position, currentPathNode.transform.position) < 0.25f)
            {
                currentPathNode = currentPathNode.GetNext();
            }
        }
    }
}