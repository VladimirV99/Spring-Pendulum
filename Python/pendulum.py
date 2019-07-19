import numpy as np
import matplotlib.pyplot as plt

g = 9.81

L0 = 1 # base length
m = 1 # mass
k = 60 # coefficient
theta = np.deg2rad(30) # starting angle

# additional tension
dx = 0
dy = 0

dt = 1e-3

X = []
Y = []

x = L0*np.sin(theta) + dx
y = -L0*np.cos(theta) + dy

vx = 0
vy = 0

ax = 0
ay = 0

X.append(x)
Y.append(y)

time = 0
total = 15 # total time in seconds

while time < total:
    theta = np.arctan2(x, np.abs(y))
    if y > 0:
        theta = np.sign(x)*np.pi - theta

    Ln = np.sqrt(x**2+y**2)

    ax = -k * (Ln - L0) * np.sin(theta) / m
    ay = k * (Ln - L0) * np.cos(theta) / m - g
	# alternative
    # ax = -k * (Ln-L0)*x/Ln/m
    # ay = -k * (Ln-L0)*y/Ln/m - g

    vx = vx + ax*dt
    vy = vy + ay*dt

    x += vx*dt
    y += vy*dt

    X.append(x)
    Y.append(y)

    time += dt

    # print(x, y, ax, ay, vx, vy, np.rad2deg(theta))

plt.axis('equal')
plt.plot(np.array(X), np.array(Y)) # draw path
plt.plot(0, 0, 'ro') # draw pivot
plt.show()

