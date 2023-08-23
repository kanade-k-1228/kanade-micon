### Sine Wave Oscilator

leap-frog method

$$
\left\{
    \begin{align*}
        s(t) = A\sin(2\pi f t) \\
        c(t) = A\cos(2\pi f t)
    \end{align*}
\right.
$$

$$
s'(t) = 2\pi f c(t)
$$

$$
\frac{s(t+\Delta t) - s(t)}{\Delta t} = 2\pi f c\left(t+\frac{\Delta t}{2}\right)
$$

$k:=2\pi f \Delta t$

$$
\left\{
    \begin{align*}
        s(t+\Delta t) = s(t) + k c\left(t+\frac{\Delta t}{2}\right) \\
        c\left(t+\frac{\Delta t}{2}\right) = c\left(t-\frac{\Delta t}{2}\right) - k s(t)
    \end{align*}
\right.
$$

参考：https://www.acri.c.titech.ac.jp/wordpress/archives/12227
