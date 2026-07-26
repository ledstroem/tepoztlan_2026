import { describe,expect,it } from 'vitest';import { smootherstep } from '../src/math/easing';
describe('smootherstep',()=>{it('is bounded and has smooth endpoints',()=>{expect(smootherstep(0)).toBe(0);expect(smootherstep(1)).toBe(1);expect(smootherstep(.5)).toBeCloseTo(.5);expect(smootherstep(-1)).toBe(0);expect(smootherstep(2)).toBe(1);});});
