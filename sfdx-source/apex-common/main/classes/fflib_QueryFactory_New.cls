public inherited sharing class fflib_QueryFactory_New
	implements fflib_IQueryFactory_New
{
    // ========== fflib_IQueryFactoryBase implementation ==========================================

	public fflib_IQueryFactory_New addOrdering(fflib_QueryFactory_New.Ordering ordering)
	{
		orderingsList.add(ordering);
		return this;
	}

	public fflib_IQueryFactory_New addOrdering(String fieldName, SortOrder direction)
	{
		return addOrdering(fieldName, direction, false);
	}

	public fflib_IQueryFactory_New addOrdering(String fieldName, SortOrder direction, Boolean nullsLast)
	{
		orderingsList.add(new Ordering(fieldName, direction, nullsLast));
		return this;
	}

	public String getCondition()
	{
		return this.stringBasedQueryFactory.getCondition();
	}

	public Set<String> getFields()
	{
		return this.stringBasedQueryFactory.getFields();
	}

	public Integer getLimit()
	{
		return this.stringBasedQueryFactory.getLimit();
	}

	public Integer getOffset()
	{
		return this.stringBasedQueryFactory.getOffset();
	}

	public String getOrderingClause()
	{
		return stringBasedQueryFactory.getOrderingClause();
	}

	public List<fflib_QueryFactory_New.Ordering> getOrderings()
	{
		return orderingsList;
	}

	public List<String> getSelectedFields()
	{
		List<String> out = this.stringBasedQueryFactory.getSelectedFields();

		for (SObjectField sof : this.selectSObjectFields)
		{
			out.add(sof.getDescribe().getName());
		}
		return out;
	}

	public List<fflib_IQueryFactory_New> getSubselectQueries()
	{
		return this.subselectQueryMap.values();
	}

	public SObjectType getTable()
	{
		return this.table;
	}

	public String getWhereClause()
	{
		return stringBasedQueryFactory.getWhereClause();
	}

	public fflib_IQueryFactory_New selectField(String fieldName)
	{
		this.stringBasedQueryFactory.selectField(getFieldPath(fieldName));
		return this;
	}

	public fflib_IQueryFactory_New selectFields(List<String> fieldNameList)
	{
		List<String> validatedFieldList = new List<String>();

		for (String fld : fieldNameList)
		{
			validatedFieldList.add(getFieldPath(fld));
		}

		this.stringBasedQueryFactory.selectFields(validatedFieldList);
		return this;
	}

	public fflib_IQueryFactory_New selectFields(Set<String> fieldNameSet)
	{
		List<String> validatedFieldList = new List<String>();

		for (String fld : fieldNameSet)
		{
			validatedFieldList.add(getFieldPath(fld));
		}

		this.stringBasedQueryFactory.selectFields(validatedFieldList);
		return this;
	}

	public fflib_IQueryFactory_New setCondition(String clause)
	{
		this.stringBasedQueryFactory.setCondition(clause);
		return this;
	}

	public fflib_IQueryFactory_New setLimit(Integer value)
	{
		this.stringBasedQueryFactory.setLimit(value);
		return this;
	}

	public fflib_IQueryFactory_New setOffset(Integer value)
	{
		this.stringBasedQueryFactory.setOffset(value);
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(fflib_QueryFactory_New.Ordering ordering)
	{
		orderingsList.clear();
		orderingsList.add(ordering);
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(String fieldName, SortOrder direction)
	{
		return setOrdering(fieldName, direction, false);
	}

	public fflib_IQueryFactory_New setOrdering(String fieldName, SortOrder direction, Boolean nullsLast)
	{
		return setOrdering(new Ordering(fieldName, direction, nullsLast));
	}

	public fflib_IQueryFactory_New setSortSelectFields(Boolean value)
	{
		this.stringBasedQueryFactory.setSortSelectFields(value);
		return this;
	}

	public fflib_IQueryFactory_New subselectQuery(String relationshipName)
	{
		return subselectQuery(relationshipName, false);
	}

	public String toSOQL()
	{
		List<String> sb = new List<String> {'SELECT'};

		List<String> fieldsSb = getSelectedFields();

		for (fflib_IQueryFactory_New subQf : subselectQueryMap.values())
		{
			fieldsSb.add('(' + subQf.toSOQL() + ')');
		}

		if (fieldsSb.isEmpty())
		{
			fieldsSb.add('Id');
		}

		sb.add(String.join(fieldsSb, ', '));

		sb.add('FROM');

		if (relationship == null)
		{
			sb.add(table.getDescribe().getName());
		}
		else
		{
			sb.add(relationship.relationshipName);
		}

		conditionallyAddToStringBuilder(sb, getWhereClause());

		conditionallyAddToStringBuilder(sb, getOrderingClause());

		if (0 < getLimit())
		{
			sb.add('LIMIT ' + getLimit());
		}

		if (0 < getOffset())
		{
			sb.add('OFFSET ' + getOffset());
		}

		return String.join(sb, ' ');
	}

	// ========== fflib_IQueryFactory_New implementation ==========================================
	public fflib_IQueryFactory_New addOrdering(SObjectField field, SortOrder direction, Boolean nullsLast)
	{
		stringBasedQueryFactory.addOrdering(getFieldTokenPath(field), fflib_Ordering.SortOrder.valueOf(direction.name()), nullsLast);
		return this;
	}

	public fflib_IQueryFactory_New addOrdering(SObjectField field, SortOrder direction)
	{
		stringBasedQueryFactory.addOrdering(getFieldTokenPath(field), fflib_Ordering.SortOrder.valueOf(direction.name()));
		return this;
	}

	public fflib_IQueryFactory_New assertIsAccessible()
	{
		fflib_SecurityUtils.checkObjectIsReadable(table);
		return this;
	}

	public fflib_IQueryFactory_New deepClone()
	{
		fflib_QueryFactory_New clone = new fflib_QueryFactory_New(this.table, null);
		clone.setLimit(getLimit());
		clone.setOffset(getOffset());
		clone.setCondition(getCondition());
		clone.setEnforceFLS(this.enforceFLS);

		Map<String, fflib_IQueryFactory_New> subqueries = this.subselectQueryMap;
		if(subqueries != null) {
			Map<String, fflib_IQueryFactory_New> clonedSubqueries = new Map<String, fflib_IQueryFactory_New>();
			for(String key : subqueries.keySet()) {
				clonedSubqueries.put(key, subqueries.get(key).deepClone());
			}
			clone.subselectQueryMap = clonedSubqueries;
		}

		clone.setRelationship(this.relationship);

		for (fflib_QueryFactory_New.Ordering o : getOrderings())
		{
			clone.addOrdering(o);
		}

		clone.getStringBasedQueryFactory().selectFields(stringBasedQueryFactory.getFields());
		clone.setSelectSObjectFields(this.selectSObjectFields);

		return clone;
	}

	public Boolean equals(Object obj)
	{
		if (!(obj instanceof fflib_IQueryFactory_New))
		{
			return false;
		}

		fflib_IQueryFactory_New intfaceObj = (fflib_IQueryFactory_New) obj;

		if (intfaceObj.getTable() != this.getTable())
		{
			return false;
		}

		if (intfaceObj.getSelectedFields().size() != this.getSelectedFields().size())
		{
			return false;
		}

		return intfaceObj.toSOQL() == this.toSOQL();
	}

	public fflib_IQueryFactory_New selectField(String fieldName, SObjectType relatedSObjectType)
	{
		stringBasedQueryFactory.selectField(getFieldPath(fieldName, relatedSObjectType));
		return this;
	}

	public fflib_IQueryFactory_New selectField(SObjectField field)
	{
		if(field == null)
		{
			throw new InvalidFieldException(null, this.table);
		}

		if (enforceFLS)
		{
			fflib_SecurityUtils.checkFieldIsReadable(table, field);
		}

		stringBasedQueryFactory.selectField( getFieldTokenPath(field) );
		return this;
	}

	public fflib_IQueryFactory_New selectFields(List<SObjectField> fields)
	{
		for(Schema.SObjectField token:fields)
		{
			if(token == null)
			{
				throw new InvalidFieldException();
			}

			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(table, token);
			}

			stringBasedQueryFactory.selectField( getFieldTokenPath(token) );
		}
		return this;
	}

	public fflib_IQueryFactory_New selectFields(Set<SObjectField> fields)
	{
		selectFields(new List<SObjectField>(fields));
		return this;
	}

	public fflib_IQueryFactory_New selectFieldSet(FieldSet fieldSet)
	{
		selectFieldSet(fieldSet, true);
		return this;
	}

	public fflib_IQueryFactory_New selectFieldSet(FieldSet fieldSet, Boolean allowCrossObject)
	{
		if (fieldSet.getSObjectType() != table)
		{
			throw new InvalidFieldSetException('Field set "' + fieldSet.getName() + '" is not for SObject type "' + table + '"');
		}

		for (FieldSetMember field: fieldSet.getFields())
		{
			if (!allowCrossObject && field.getFieldPath().contains('.'))
			{
				throw new InvalidFieldSetException('Cross-object fields not allowed and field "' + field.getFieldPath() + '"" is a cross-object field.');
			}
			stringBasedQueryFactory.selectField( getFieldTokenPath(field.getSObjectField()) );
		}

		return this;
	}

	public fflib_IQueryFactory_New setEnforceFLS(Boolean enforce)
	{
		enforceFLS = enforce;
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(SObjectField field, SortOrder direction)
	{
		setOrdering(field, direction, false);
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(SObjectField field, SortOrder direction, Boolean nullsLast)
	{
		setOrdering(new Ordering(getFieldTokenPath(field), direction, nullsLast));
		return this;
	}

	public fflib_IQueryFactory_New subselectQuery(SObjectType related)
	{
		return subselectQuery(related, false);
	}

	public fflib_IQueryFactory_New subselectQuery(SObjectType related, Boolean assertIsAccessible)
	{
		return setupSubselectQuery(related, assertIsAccessible);
	}

	public fflib_IQueryFactory_New subselectQuery(ChildRelationship relationship)
	{
		return subselectQuery(relationship, false);
	}

	public fflib_IQueryFactory_New subselectQuery(ChildRelationship relationship, Boolean assertIsAccessible)
	{
		return setupSubselectQuery(relationship, assertIsAccessible);
	}

	public fflib_IQueryFactory_New subselectQuery(String relationshipName, Boolean assertIsAccessible)
	{
		return setupSubselectQuery(relationshipName, assertIsAccessible);
	}

	// ========== Private Construction Logic ======================================================
	private fflib_QueryFactory_New(SObjectType table, fflib_IQueryFactoryBase stringBasedQueryFactory)
	{
		this.table = table;

		if (stringBasedQueryFactory == null)
		{
			this.stringBasedQueryFactory = fflib_QueryFactoryBase.newInstance(table.getDescribe().getName());
		}
		else
		{
			this.stringBasedQueryFactory = stringBasedQueryFactory;
		}
	}

	private fflib_QueryFactory_New(ChildRelationship relationship)
	{
		this.stringBasedQueryFactory = fflib_QueryFactoryBase.newInstance(relationship.childSObject.getDescribe().getName());
		this.table = relationship.childSObject;
		this.relationship = relationship;
	}

	// ========== Private Instance Logic ==========================================================
	private fflib_IQueryFactoryBase stringBasedQueryFactory;
	private Boolean assertIsAccessible = false;
	private Boolean enforceFLS = false;
	private SObjectType table;
	private Set<SObjectField> selectSObjectFields = new Set<SObjectField>();
	private List<Ordering> orderingsList = new List<fflib_QueryFactory_New.Ordering>();

	// Subselect query fields
	private ChildRelationship relationship;
	private Map<String, fflib_IQueryFactory_New> subselectQueryMap = new Map<String, fflib_IQueryFactory_New>();

	private ChildRelationship getChildRelationship(SObjectType objType)
	{
		for (ChildRelationship childRow : table.getDescribe().getChildRelationships())
		{
			//occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.
			//if there is no relationship name, we cannot query on it, so throw an exception.
			if (childRow.getChildSObject() == objType && childRow.getRelationshipName() != null)
			{
				return childRow;
			}
		}

		throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  Invalid relationship for table '+table + ' and objtype='+objType);
	}

	private String getFieldPath(String fieldName)
	{
		return getFieldPath(fieldName, table);
	}

	private String getFieldPath(String fieldName, SObjectType relatedSObjectType)
	{
		if(!fieldName.contains('.'))
		{
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(this.table).getField(fflib_QueryFactory_New.keyify(fieldName));
			if (token == null)
			{
				throw new InvalidFieldException(fieldName, this.table);
			}
			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(this.table, token);
			}
			return getFieldTokenPath(token);
		}

		List<String> fieldPath = new List<String>();
		SObjectType lastSObjectType = this.table;
		Iterator<String> i = fieldName.split('\\.').iterator();
		while(i.hasNext())
		{
			String field = i.next();
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(fflib_QueryFactory_New.keyify(field));
			DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;

			if (token == null)
			{
				throw new InvalidFieldException(field, lastSObjectType);
			}

			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(lastSObjectType, token);
			}

			if (i.hasNext() && tokenDescribe.getSoapType() == SoapType.ID)
			{
				List<SObjectType> relatedObjs = tokenDescribe.getReferenceTo(); //if it's polymorphic, it matters which one we use - i.e. Lead.Owner is GROUP|USER and each has different fields.

				if (relatedObjs.size() == 1 || relatedSObjectType == null)
				{
					lastSObjectType = relatedObjs[0]; //caller did not specify the one to use or there's only one so use the first one
				}
				else
				{
					for (SObjectType sot : relatedObjs)
					{
						if (fflib_SObjectDescribe.getDescribe(sot).getDescribe().getSObjectType() == relatedSObjectType)
						{
							lastSObjectType = sot;
							break;
						}
					}
				}

				fieldPath.add(tokenDescribe.getRelationshipName());
				continue;
			}
			else if (!i.hasNext())
			{
				fieldPath.add(tokenDescribe.getName());
				continue;
			}

			throw new NonReferenceFieldException(lastSObjectType + '.' + field + ' is not a lookup or master-detail field but is used in a cross-object query field.');
		}

		return String.join(fieldPath,'.');
	}

	private fflib_IQueryFactoryBase getStringBasedQueryFactory()
	{
		return stringBasedQueryFactory;
	}

	private void setRelationship(ChildRelationship relationship)
	{
		this.relationship = relationship;
	}

	private void setSelectSObjectFields(Set<SObjectField> sobjFields)
	{
		this.selectSObjectFields = sobjFields;
	}

	private fflib_IQueryFactory_New setupSubselectQuery(String relationshipName, Boolean assertIsAccessible)
	{
		ChildRelationship cr = findChildRelationshipByRelationshipName(getTable(), relationshipName);

		if (cr == null)
		{
			throw new InvalidSubqueryRelationshipException('Child relationship not found for "' + relationshipName + '" on "' + getTable().getDescribe().getName() + '".');
		}

		return setupSubselectQuery(cr, assertIsAccessible);
	}

	private fflib_IQueryFactory_New setupSubselectQuery(ChildRelationship childRelationship, Boolean assertIsAccessible)
	{
		if (subselectQueryMap.containsKey(childRelationship.relationshipName))
		{
			return subselectQueryMap.get(childRelationship.relationshipName);
		}

		// Assert this is NOT a subquery for a subquery, which violates a Salesforce limit.
		// Reference: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_relationships_query_limits.htm
		if (this.relationship != null)
		{
			throw new InvalidSubqueryRelationshipException('Salesforce SOQL limits subqueries to a depth of 1 level.');
		}

		fflib_IQueryFactory_New newSubselectQuery = fflib_QueryFactory_New.newInstance(childRelationship);

		if (assertIsAccessible)
		{
			newSubselectQuery.assertIsAccessible();
		}

		subselectQueryMap.put(childRelationship.relationshipName, newSubselectQuery);
		return newSubselectQuery;
	}

	private fflib_IQueryFactory_New setupSubselectQuery(SObjectType sobjType, Boolean assertIsAccessible)
	{
		ChildRelationship cr = findChildRelationshipBySObjectType(getTable(), sobjType);

		return setupSubselectQuery(cr, assertIsAccessible);
	}

	// ========== Static Instancing Logic =========================================================
	private static Map<SObjectType, fflib_IQueryFactory_New> mockInstanceMap = new Map<SObjectType, fflib_IQueryFactory_New>();

	@TestVisible
	private static void setMock(SObjectType table, fflib_IQueryFactory_New mock)
	{
		mockInstanceMap.put(table, mock);
	}

	public static fflib_IQueryFactory_New newInstance(SObjectType table)
	{
		if (table == null)
		{
			throw new InvalidTableException('"table" is required');
		}

		return
			!mockInstanceMap.containsKey(table)
			? new fflib_QueryFactory_New(table, null)
			: mockInstanceMap.get(table);
	}

	public static fflib_IQueryFactory_New newInstance(SObjectType table, fflib_IQueryFactoryBase stringBasedQueryFactory)
	{
		if (table == null)
		{
			throw new InvalidTableException('"table" is required');
		}

		return
				!mockInstanceMap.containsKey(table)
						? new fflib_QueryFactory_New(table, stringBasedQueryFactory)
						: mockInstanceMap.get(table);
	}

	private static fflib_IQueryFactory_New newInstance(ChildRelationship relationship)
	{
		return new fflib_QueryFactory_New(relationship);
	}

	// ========== Private Static Logic ============================================================
	private static void conditionallyAddToStringBuilder(List<String> sb, String value)
	{
		if (String.isNotBlank(value))
		{
			sb.add(value);
		}
	}

	private static ChildRelationship findChildRelationshipByRelationshipName(SObjectType parentSObjectType, String relationshipName)
	{
		if (parentSObjectType == null)
		{
			throw new InvalidSubqueryRelationshipException('\'parentSObjectType\' is required.');
		}

		for (ChildRelationship cr : parentSObjectType.getDescribe().childRelationships)
		{
			if (String.isNotBlank(cr.relationshipName) && cr.relationshipName.equalsIgnoreCase(relationshipName))
			{
				return cr;
			}
		}

		return null;
	}

	private static ChildRelationship findChildRelationshipBySObjectType(SObjectType parentSObjectType, SObjectType childSObjectType)
	{
		if (parentSObjectType == null)
		{
			throw new InvalidSubqueryRelationshipException('\'parentSObjectType\' is required.');
		}

		if (childSObjectType == null)
		{
			throw new InvalidSubqueryRelationshipException('\'childSObjectType\' is required.');
		}

		for (ChildRelationship cr : parentSObjectType.getDescribe().childRelationships)
		{
			if (cr.childSObject == childSObjectType)
			{
				return cr;
			}
		}

		return null;
	}

	private static ChildRelationship findChildRelationshipBySObjectType(SObjectType parentSObjectType, String childSObjectTypeName)
	{
		if (parentSObjectType == null)
		{
			throw new InvalidSubqueryRelationshipException('\'parentSObjectType\' is required.');
		}

		if (String.isBlank(childSObjectTypeName))
		{
			throw new InvalidSubqueryRelationshipException('\'childSObjectTypeName\' is required.');
		}

		for (ChildRelationship cr : parentSObjectType.getDescribe().childRelationships)
		{
			if (cr.childSObject.getDescribe().getName().equalsIgnoreCase(childSObjectTypeName))
			{
				return cr;
			}
		}

		return null;
	}

	@TestVisible
	private static String getFieldTokenPath(SObjectField field)
	{
		if(field == null){
			throw new InvalidFieldException('Invalid field: null');
		}
		return field.getDescribe().getName();
	}

	private static String keyify(String value)
	{
		return value?.trim().toLowerCase();
	}

	// ========== Inner Classes ===================================================================
	public enum SortOrder {ASCENDING, DESCENDING}
	public class Ordering
		extends fflib_Ordering
	{
		public Ordering(SObjectField field, fflib_QueryFactory_New.SortOrder direction)
		{
			super(field, fflib_Ordering.SortOrder.valueOf(direction.name()));
		}

		public Ordering(String fieldName, fflib_QueryFactory_New.SortOrder direction, Boolean nullsLast)
		{
			super(fieldName, fflib_Ordering.SortOrder.valueOf(direction.name()), nullsLast);
		}

		public Ordering(String tableName, String fieldName, fflib_QueryFactory_New.SortOrder direction)
		{
			super(tableName, fieldName, fflib_Ordering.SortOrder.valueOf(direction.name()));
		}

		public Ordering(String tableName, String fieldName, fflib_QueryFactory_New.SortOrder direction, Boolean assertSchema)
		{
			super(tableName, fieldName, fflib_Ordering.SortOrder.valueOf(direction.name()), assertSchema);
		}
	}

	// ========== Exception Classes ===============================================================
	public class AccessibilityException
			extends Exception
	{

	}

	public class InvalidChildRelationshipException
			extends Exception
	{
		private String fieldName;
		private Schema.SObjectType objectType;
		public InvalidChildRelationshipException(String fieldName, Schema.SObjectType objectType){
			this.objectType = objectType;
			this.fieldName = fieldName;
			this.setMessage( 'Invalid field \''+fieldName+'\' for object \''+objectType+'\'' );
		}
	}

	public class InvalidFieldException
		extends Exception
	{
		private String fieldName;
		private Schema.SObjectType objectType;
		public InvalidFieldException(String fieldName, Schema.SObjectType objectType){
			this.objectType = objectType;
			this.fieldName = fieldName;
			this.setMessage( 'Invalid field \''+fieldName+'\' for object \''+objectType+'\'' );
		}
	}

	public class InvalidFieldSetException
		extends Exception
	{

	}

	public class InvalidSubqueryRelationshipException
		extends Exception
	{

	}

	public class InvalidTableException
		extends Exception
	{

	}

	public class NonReferenceFieldException
		extends Exception
	{

	}
}