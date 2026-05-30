export interface Task {
  id: string;
  title: string;
  done: boolean;
  createdAt: string;
}

export interface TaskStore {
  list(): Promise<Task[]>;
  create(title: string): Promise<Task>;
  toggle(id: string): Promise<Task | undefined>;
  remove(id: string): Promise<boolean>;
}
