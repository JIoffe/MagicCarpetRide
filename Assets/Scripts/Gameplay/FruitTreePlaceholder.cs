using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Gameplay
{
    public class FruitTreePlaceholder : MonoBehaviour
    {
        [Tooltip("Prefabs that can possibly spawn here")]
        public GameObject[] fruitTrees;

        void Awake()
        {
            var pos = transform.position;
            var parent = transform.parent;

            var fruitTree = GetFruitTreePrefab();
            if(fruitTrees != null)
            {
                var instance = Instantiate(fruitTree, parent);
                instance.transform.position = pos;
            }

            Destroy(gameObject);
        }

        GameObject GetFruitTreePrefab()
        {
            if (fruitTrees.Length == 0)
                return null;

            return fruitTrees[Random.Range(0, fruitTrees.Length)];
        }
    }
}