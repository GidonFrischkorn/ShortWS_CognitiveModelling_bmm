import assert from 'node:assert/strict';
import {calloutGeometry} from '../slides/formula-callouts.js';

for (const anchorX of [30, 280, 530]) {
  const bubble = calloutGeometry(anchorX, 135, 120, 220, 44, 560);
  assert.ok(bubble.x >= 8 && bubble.x + 220 <= 552);
  assert.ok(bubble.y + 44 < 120);
  assert.equal(bubble.tipX, anchorX);
  assert.equal(bubble.tipY, 131);
  assert.ok(bubble.path.trim().endsWith('Z'));
}
console.log('Callouts remain within their panel and point to the anchor above the formula.');
