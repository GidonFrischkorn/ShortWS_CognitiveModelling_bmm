// Reveal re-cues data-autoslide only on slide changes and key presses, so a
// fragment chain reached with the on-screen controls or a click never advances
// by itself. On slides without their own autoslide, advance after a shown
// fragment's data-autoslide delay. The extra slack lets Reveal's own timer win
// when it is running; its advance fires fragmentshown, which cancels this one.
const SLACK = 50;
let timer;
const cancel = () => clearTimeout(timer);

function schedule() {
  const slide = Reveal.getCurrentSlide();
  if (Number(slide.dataset.autoslide || 0) > 0) return;
  // Same rule as Reveal: only the current fragment's delay counts.
  const current = slide.querySelectorAll('.current-fragment[data-autoslide]');
  const delay = Math.max(0, ...Array.from(current, f => Number(f.dataset.autoslide)));
  if (delay > 0) timer = setTimeout(() => Reveal.next(), delay + SLACK);
}

// fragmentshown can fire before Reveal moves .current-fragment, so read it a
// tick later.
function cue() {
  cancel();
  timer = setTimeout(schedule, 0);
}

if (typeof window !== 'undefined' && window.Reveal) {
  Reveal.on('fragmentshown', cue);
  ['fragmenthidden', 'slidechanged'].forEach(event => Reveal.on(event, cancel));
}
