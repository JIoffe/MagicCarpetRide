using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Gameplay
{
    public class FruitTree : MonoBehaviour
    {

        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        public void OnPointerEnter()
        {

        }

        public void OnPointerExit()
        {

        }

        public void OnPointerClick()
        {
            var collectableFruit = GetComponentsInChildren<CollectableFruit>();

            foreach (var fruit in collectableFruit)
                fruit.OnCollect();

            var targetArrow = GetComponentInChildren<TargetArrow>();
            if(targetArrow != null)
            {
                Destroy(targetArrow.gameObject);
            }
        }
    }
}