export function calloutGeometry(anchorX, anchorY, formulaTop, width, height, panelWidth) {
  const x = Math.max(8, Math.min(anchorX - width / 2, panelWidth - width - 8));
  const y = formulaTop - height - 16;
  const tipX = anchorX;
  const tipY = anchorY - 4;
  const base = Math.max(x + 20, Math.min(tipX, x + width - 20));
  const right = x + width;
  const bottom = y + height;
  const path = `M ${x + 10} ${y} H ${right - 10} Q ${right} ${y} ${right} ${y + 10}
    V ${bottom - 10} Q ${right} ${bottom} ${right - 10} ${bottom}
    H ${base + 10} L ${tipX} ${tipY} L ${base - 10} ${bottom}
    H ${x + 10} Q ${x} ${bottom} ${x} ${bottom - 10}
    V ${y + 10} Q ${x} ${y} ${x + 10} ${y} Z`;
  return {x, y, tipX, tipY, path};
}

function positionCallouts() {
  document.querySelectorAll('.m3-formula-callout').forEach(callout => {
    const svg = callout.querySelector('svg');
    const equation = callout.closest('.m3-choice-equation');
    const formula = equation.querySelector('math');
    const numerator = formula.querySelector('mfrac')?.firstElementChild;
    const anchor = Array.from(numerator?.querySelectorAll('msub') ?? [])
      .find(node => node.firstElementChild.textContent === 'A');
    const box = callout.getBoundingClientRect();
    if (!anchor || !box.width || !callout.clientWidth) return;
    anchor.classList.add('m3-callout-anchor');
    const scaleX = box.width / callout.clientWidth;
    const scaleY = box.height / callout.clientHeight;
    const target = anchor.getBoundingClientRect();
    const label = callout.querySelector('.m3-callout-label');
    const width = label.offsetWidth;
    const height = label.offsetHeight;
    const geometry = calloutGeometry(
      ((target.left + target.right) / 2 - box.left) / scaleX,
      (target.top - box.top) / scaleY,
      (formula.getBoundingClientRect().top - box.top) / scaleY,
      width, height, callout.clientWidth
    );
    svg.setAttribute('viewBox', `0 0 ${callout.clientWidth} ${callout.clientHeight}`);
    svg.querySelector('path').setAttribute('d', geometry.path);
    label.style.left = `${geometry.x}px`;
    label.style.top = `${geometry.y}px`;
  });
}

if (typeof document !== 'undefined') {
  const update = () => requestAnimationFrame(positionCallouts);
  ['ready', 'slidetransitionend', 'fragmentshown', 'fragmenthidden', 'resize']
    .forEach(event => window.Reveal?.on(event, update));
  window.addEventListener('resize', update);
  document.fonts.ready.then(update);
  update();
}
