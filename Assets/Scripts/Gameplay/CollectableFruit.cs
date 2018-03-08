using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicForestRide.Gameplay
{
    public class CollectableFruit : MonoBehaviour
    {
        [Tooltip("The speed at which collected fruit will fly towards the sky")]
        public float collectionAnimationSpeed = 2f;

        [Tooltip("The time in seconds that collected fruit will fly towards the sky before disappearing")]
        public float collectionAnimationDuration = 3f;

        private bool isCollected = false;

        public void OnCollect()
        {
            if (!isCollected)
            {
                StartCoroutine(CollectionAnimation());
                isCollected = true;
            }
        }

        IEnumerator CollectionAnimation()
        {
            var particleSystems = GetComponentsInChildren<ParticleSystem>();
            foreach (var particleSystem in particleSystems)
                particleSystem.Play();

            var animTime = 0f;

            while (animTime < collectionAnimationDuration)
            {
                var delta = Vector3.up * collectionAnimationSpeed * Time.deltaTime;
                transform.Translate(delta);
                animTime += Time.deltaTime;
                yield return null;
            }

            Destroy(gameObject);
        }
    }
}