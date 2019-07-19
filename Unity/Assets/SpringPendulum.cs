using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SpringPendulum : MonoBehaviour
{
    public GameObject Pivot;
    public GameObject Bob;
    public GameObject VisualBob;

    public Text angleText;
    public Text lengthText;

    public Text sliderLengthText;
    public Text sliderMassText;
    public Text sliderCoefficientText;

    public float mass = 1f;
    public float ropeLength = 3f;
    public float theta0 = 30 * Mathf.Deg2Rad;
    public float k = 20f;

    private Vector3 bobStartingPosition;
    private float theta;
    private float Ln;
    private bool dragging = false;
    private bool isRope = false;

    private Vector3 gravityDirection;
    private Vector3 tensionDirection;

    private float tensionForce = 0f;
    private float gravityForce = 0f;

    Vector3 currentVelocity = new Vector3();

    public void LengthChanged(float value)
    {
        this.ropeLength = value;
        this.sliderLengthText.text = "Length: " + this.ropeLength.ToString("F2") + "m";
    }

    public void MassChanged(float value)
    {
        this.mass = value;
        this.ScaleBob();
        this.sliderMassText.text = "Mass: " + this.mass.ToString("F2") + "kg";
    }

    public void CoefficientChanged(float value)
    {
        this.k = value;
        this.sliderCoefficientText.text = "Coefficient: " + this.k;
    }

    public void toggleRope(bool value)
    {
        this.isRope = value;
    }

    void Start()
    {
        //Application.targetFrameRate = -1;
        this.bobStartingPosition = this.Bob.transform.position;

        this.gravityForce = this.mass * 9.81f;
        this.gravityDirection = new Vector3(0, -1, 0);

        this.PendulumInit();
    }

    void Update()
    {
        Vector3 pos = Bob.transform.position - Pivot.transform.position;
        this.CalculateAngle(pos);
        this.CalculateLength(pos);
        if (!dragging)
        {
            float deltaTime = Time.deltaTime;
            this.CalculateSpringForce();
            currentVelocity += (tensionDirection * tensionForce * deltaTime / mass + gravityDirection * gravityForce * deltaTime);
            this.Bob.transform.position += currentVelocity * deltaTime;
            this.VisualBob.transform.position = this.Bob.transform.position;
        }
    }

    void OnMouseDrag()
    {
        dragging = true;
        Vector3 Screepoint = Camera.main.WorldToScreenPoint(VisualBob.transform.position);

        Vector3 mouseposition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, Screepoint.z);

        Vector3 objposition = Camera.main.ScreenToWorldPoint(mouseposition);

        Bob.transform.position = new Vector3(objposition.x, objposition.y, 0);
        VisualBob.transform.position = new Vector3(objposition.x, objposition.y, 0);
    }

    void OnMouseUp()
    {
        dragging = false;
        this.ResetPendulumForces();
    }

    [ContextMenu("Reset Pendulum Position")]
    void ResetPendulumPosition()
    {
        Bob.transform.position = bobStartingPosition;
        VisualBob.transform.position = bobStartingPosition;
    }

    [ContextMenu("Reset Pendulum Forces")]
    void ResetPendulumForces()
    {
        this.currentVelocity = Vector3.zero;
    }

    public void PendulumInit()
    {
        LengthChanged(this.ropeLength);
        MassChanged(this.mass);
        CoefficientChanged(this.k);
        this.theta = this.theta0;
        this.Ln = this.ropeLength;
        this.bobStartingPosition = Pivot.transform.position + new Vector3(-ropeLength * Mathf.Sin(theta), -ropeLength * Mathf.Cos(theta));
        this.ResetPendulumPosition();
        this.ResetPendulumForces();
    }

    void ScaleBob()
    {
        this.VisualBob.transform.localScale = new Vector3(1f + mass * 0.1f, 1f + mass * 0.1f, 1f + mass * 0.1f);
    }

    void CalculateAngle(Vector3 pos)
    {
        this.theta = Mathf.Atan2(pos.x, Mathf.Abs(pos.y));
        if (pos.y > 0)
        {
            theta = Mathf.Sign(pos.x) * Mathf.PI - theta;
        }

        this.angleText.text = "Angle: " + (theta * Mathf.Rad2Deg).ToString("F2") + "°";
    }

    void CalculateLength(Vector3 pos)
    {
        this.Ln = Mathf.Sqrt(pos.x * pos.x + pos.y * pos.y);

        this.lengthText.text = "Length: " + Ln.ToString("F2") + "m";
    }

    void CalculateSpringForce()
    {
        if (this.isRope && Ln - ropeLength < 0)
        {
            this.tensionForce = 0;
        }
        else
        {
            float Fx = -k * (Ln - ropeLength) * Mathf.Sin(theta);
            float Fy = k * (Ln - ropeLength) * Mathf.Cos(theta);
            // float Fx = -k * (Ln - ropeLength) * pos.x / Ln;
            // float Fy = -k * (Ln - ropeLength) * pos.y / Ln;
            this.tensionDirection = new Vector3(Fx, Fy, 0).normalized;
            this.tensionForce = Mathf.Sqrt(Fx * Fx + Fy * Fy);
        }
    }

    void OnDrawGizmos()
    {
        // Purple
        Gizmos.color = new Color(.5f, 0f, .5f);
        Gizmos.DrawWireSphere(this.Pivot.transform.position, this.ropeLength);

        if(!dragging)
        {
            // Blue: Auxilary
            Gizmos.color = new Color(.3f, .3f, 1f);
            Vector3 auxVel = .5f * this.currentVelocity;
            Gizmos.DrawRay(this.Bob.transform.position, auxVel);
            Gizmos.DrawSphere(this.Bob.transform.position + auxVel, .2f);

            // Yellow: Gravity
            Gizmos.color = new Color(1f, 1f, .2f);
            Vector3 gravity = .5f * this.gravityForce * this.gravityDirection;
            Gizmos.DrawRay(this.Bob.transform.position, gravity);
            Gizmos.DrawSphere(this.Bob.transform.position + gravity, .2f);

            // Orange: Tension
            Gizmos.color = new Color(1f, .5f, .2f);
            Vector3 tension = 0.2f * (this.tensionForce > 10 ? 10 : this.tensionForce) * this.tensionDirection;
            Gizmos.DrawRay(this.Bob.transform.position, tension);
            Gizmos.DrawSphere(this.Bob.transform.position + tension, .2f);

            // Red: Resultant
            Gizmos.color = new Color(1f, .3f, .3f);
            Vector3 resultant = gravity + tension;
            Gizmos.DrawRay(this.Bob.transform.position, resultant);
            Gizmos.DrawSphere(this.Bob.transform.position + resultant, .2f);
        }
    }
}