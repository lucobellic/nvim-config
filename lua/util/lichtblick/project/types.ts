import type { MessageEvent, Time as SuiteTime } from '@lichtblick/suite';

export type Message<_SchemaName extends string> = unknown;

export type Input<T extends string, TMessage = unknown> = Omit<MessageEvent<TMessage>, 'topic'> & {
  topic: T;
};

export type Time = SuiteTime;

export type RGBA = {
  r: number;
  g: number;
  b: number;
  a: number;
};

export type Header = {
  frame_id: string;
  stamp: Time;
  seq: number;
};

export type Point = {
  x: number;
  y: number;
  z: number;
};

export type Translation = Point;

export type Rotation = {
  x: number;
  y: number;
  z: number;
  w: number;
};

export type Quaternion = Rotation;

export type Pose = {
  position: Point;
  orientation: Quaternion;
};

export type Transform = {
  header: Header;
  child_frame_id: string;
  transform: {
    translation: Translation;
    rotation: Rotation;
  };
};
