interface GoodPool<T> {
  Get(): T;
  Return(item: T): void;
  Preload(amount: number): void;
  Clean(): void;
  GetSize(): number;
}

interface GoodPoolConstructor {
  new <T>(
    createFn: () => T,
    initFn: (item: T) => void,
    destroyFn?: (item: T) => void,
  ): GoodPool<T>;

  forInstance(
    templateOrClassName: Instance | string,
    setupFn: (item: Instance) => void,
  ): [GoodPool<Instance>, Instance];
}

declare const GoodPool: GoodPoolConstructor;
export = GoodPool;
