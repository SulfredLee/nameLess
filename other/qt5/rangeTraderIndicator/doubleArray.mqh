#property copyright "Copyright 2018, Damage Company"

class doubleArray
{
private:
    double m_data[];
    int m_dataLen;
public:
    doubleArray(){}
    ~doubleArray(){}

    void SetIndexBuffer(int bufferIdx);
    void ArrayInitialize();
    void ArrayFree();
    void SetValue(double value, int idx);
    int Size();
};

void doubleArray::SetIndexBuffer(int bufferIdx)
{
    SetIndexBuffer(bufferIdx, m_data, INDICATOR_DATA);
}

void doubleArray::ArrayInitialize()
{
    m_dataLen = ArrayInitialize(m_data, EMPTY_VALUE);
}

void doubleArray::SetValue(double value, int idx)
{
    m_data[idx] = value;
}

int doubleArray::Size()
{
    return m_dataLen;
}

void doubleArray::ArrayFree()
{
    ArrayFree(m_data);
}
