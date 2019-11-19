

A = [5,3,16,2,10,14]

def sort():
	buildheap()
	print("buildheap:",A)
	size = len(A)
	for i in range(size-1,0,-1):
		tmp = A[0]
		A[0] = A[i]
		A[i] = tmp
		heapify(0,i)

def buildheap():
	size = len(A)
	for i in range(size/2-1,-1,-1):
		heapify(i,size)

def heapify(idx,size):
	left = 2*idx+1
	right= 2*idx+2
	if (left < size and A[left] > A[idx]):
		largest = left
	else:
		largest = idx
	if (right < size and A[right] > A[largest]):
		largest = right
	if (largest != idx):
		tmp = A[idx]
		A[idx] = A[largest]
		A[largest] = tmp
		heapify(largest,size)
	
sort()
print("sort:",A)
